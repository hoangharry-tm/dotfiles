pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// `/` mode: file search via fd (debounced, cancellable) and, for an empty
// query, recently used files from the freedesktop recently-used.xbel.
// Results are launcher items { id, title, subtitle, icon, run, alt }.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    // Top-level dirs/globs that bury real files in noise. fd already honours
    // .gitignore and skips dotfiles, so this is just the non-ignored junk.
    // Build output and language package caches: thousands of files nobody
    // searches for by name (they drowned real results, e.g. ~/go/pkg/mod).
    readonly property var excludes: ["node_modules", ".git", ".cache", "target", "result", "__pycache__", "venv", ".venv", ".direnv", ".local/share/Trash", "go/pkg", ".cargo/registry", ".rustup", ".npm", ".pnpm-store", ".m2", ".gradle", ".local/share/nvim/lazy", ".local/share/nvim/mason", ".local/state/nix", ".nix-defexpr"]

    property string query: ""
    property var found: []   // fd hits for `query`
    property var recent: []  // parsed once when the mode opens

    // Extension -> freedesktop mime icon name (resolved by the icon theme).
    readonly property var iconByExt: ({
            pdf: "application-pdf", png: "image-x-generic", jpg: "image-x-generic", jpeg: "image-x-generic", webp: "image-x-generic", gif: "image-x-generic", svg: "image-svg+xml",
            mp4: "video-x-generic", mkv: "video-x-generic", webm: "video-x-generic", mov: "video-x-generic",
            mp3: "audio-x-generic", flac: "audio-x-generic", ogg: "audio-x-generic", wav: "audio-x-generic",
            zip: "package-x-generic", tar: "package-x-generic", gz: "package-x-generic", xz: "package-x-generic", "7z": "package-x-generic",
            doc: "x-office-document", docx: "x-office-document", odt: "x-office-document",
            xls: "x-office-spreadsheet", xlsx: "x-office-spreadsheet", csv: "x-office-spreadsheet",
            ppt: "x-office-presentation", pptx: "x-office-presentation",
            html: "text-html", sh: "text-x-script", py: "text-x-python", js: "text-x-javascript"
        })

    function iconFor(path, mime) {
        if (mime)
            return mime.replace("/", "-");
        const ext = path.slice(path.lastIndexOf(".") + 1).toLowerCase();
        return path.lastIndexOf(".") > path.lastIndexOf("/") ? (iconByExt[ext] ?? "text-x-generic") : "text-x-generic";
    }

    function item(path, mime) {
        const cut = path.lastIndexOf("/");
        const dir = path.slice(0, cut) || "/";
        return {
            id: path,
            title: path.slice(cut + 1) || path,
            subtitle: dir.startsWith(home) ? "~" + dir.slice(home.length) : dir,
            icon: mime === "inode/directory" || path.endsWith("/") ? "folder" : iconFor(path, mime),
            run: () => Quickshell.execDetached(["xdg-open", path]),
            alt: () => Quickshell.execDetached(["alacritty", "--class", "yazi", "-e", "yazi", path])
        };
    }

    // Launcher entry point: called when the text after `/` changes.
    function setQuery(q) {
        query = q;
        if (!q) {
            runner.cancel();
            found = [];
            return;
        }
        const cmd = ["fd", "--ignore-case", "--absolute-path", "--max-results", "50", "--threads", "2"];
        for (const x of excludes)
            cmd.push("--exclude", x);
        cmd.push("--", q, home);
        runner.run(cmd, q);
    }

    // Name matches first, then shallower paths: fd's order is thread-racy.
    function rank(paths, q) {
        const lq = q.toLowerCase();
        const key = p => {
            const name = p.slice(p.lastIndexOf("/") + 1).toLowerCase();
            return (name.startsWith(lq) ? 0 : name.includes(lq) ? 1000 : 2000) + p.split("/").length;
        };
        return paths.map(p => ({ p, k: key(p) })).sort((a, b) => a.k - b.k).map(x => x.p);
    }

    function items() {
        return query ? found.map(p => item(p)) : recent.map(r => item(r.path, r.mime));
    }

    // Parse recently-used.xbel (a few KB): newest 30 existing-looking file URIs.
    function refreshRecent() {
        xbel.reload();
        const text = xbel.text();
        const out = [];
        for (const chunk of text.split("</bookmark>")) {
            const m = /<bookmark href="file:\/\/([^"]+)"[^>]*modified="([^"]+)"/.exec(chunk);
            if (!m)
                continue;
            const mime = /<mime:mime-type type="([^"]+)"/.exec(chunk);
            let path;
            try {
                path = decodeURIComponent(m[1]).replace(/&amp;/g, "&").replace(/&apos;/g, "'").replace(/&quot;/g, "\"").replace(/&lt;/g, "<").replace(/&gt;/g, ">");
            } catch (e) {
                continue;
            }
            out.push({ path, mime: mime ? mime[1] : "", t: m[2] });
        }
        out.sort((a, b) => (a.t < b.t ? 1 : -1));
        recent = out.slice(0, 30);
    }

    Debounced {
        id: runner

        onDone: (output, tag) => {
            if (tag === root.query)
                root.found = root.rank(output.split("\n").filter(l => l), tag);
        }
    }

    FileView {
        id: xbel

        path: root.home + "/.local/share/recently-used.xbel"
        blockLoading: true
        printErrors: false
    }
}
