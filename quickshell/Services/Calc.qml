pragma Singleton

import QtQuick
import Quickshell

// Safe calculator: a tiny recursive-descent parser, never eval().
// Grammar: expr = term (('+'|'-') term)*; term = unary (('*'|'/'|'%') unary)*;
// unary = '-' unary | power; power = atom ('^' unary)?; atom = number | const
// | fn '(' expr ')' | '(' expr ')'.
Singleton {
    id: root

    readonly property var consts: ({ pi: Math.PI, e: Math.E, tau: 2 * Math.PI })
    readonly property var fns: ({
            sqrt: Math.sqrt, abs: Math.abs, sin: Math.sin, cos: Math.cos, tan: Math.tan,
            ln: Math.log, log: Math.log10, exp: Math.exp, round: Math.round,
            floor: Math.floor, ceil: Math.ceil
        })

    // Cheap pre-check so ordinary searches ("firefox") never reach the parser:
    // only calculator characters, with at least one digit and one operator/function.
    function looksLikeMath(s) {
        return /^[\d\s.+\-*\/%^()a-z,]+$/i.test(s) && /\d/.test(s) && /[+\-*\/%^]|\w\(/.test(s);
    }

    // --- qalc backend (units, currency): async, debounced, cancellable ---
    property string remoteExpr: ""   // expression the cached result belongs to
    property string remoteText: ""
    property bool ratesChecked: false

    // "5 km to mi", "20 usd to vnd", "3 h in min": number, then a conversion word.
    function looksLikeUnits(s) {
        return /^[-+]?[\d.,]+\s*[^\d\s].*\s(to|in|->|→)\s+[^\s\d]+$/i.test(s);
    }

    // qalc result for `expr` once it arrives, else "" (UI shows nothing meanwhile).
    function remote(expr) {
        return remoteExpr === expr ? remoteText : "";
    }

    function ask(expr) {
        if (!expr) {
            qalc.cancel();
            return;
        }
        if (!ratesChecked) {
            ratesChecked = true;
            Quickshell.execDetached(["qalc-rates"]); // no-op if refreshed within a day
        }
        // "to -mi": the minus stops qalc splitting into mixed units (3 mi + 188 yd + ...).
        const q = expr.replace(/\b(to|in)\s+([a-zA-Z_]\w*)\s*$/i, "$1 -$2");
        qalc.run(["qalc", "-t", "--", q], expr);
    }

    Debounced {
        id: qalc

        onDone: (output, tag) => {
            const line = output.split("\n")[0].trim();
            root.remoteText = line === tag ? "" : line;
            root.remoteExpr = tag;
        }
    }

    // Returns the result as a string, or "" if the input isn't a valid expression.
    function evaluate(input) {
        const toks = input.toLowerCase().replace(/,/g, ".").match(/\d+\.?\d*|\.\d+|[a-z]+|[-+*\/%^()]|\S/g) ?? [];
        let i = 0;
        const fail = () => { throw new Error("bad"); };
        const peek = () => toks[i];
        const take = t => {
            if (toks[i] !== t)
                return false;
            i++;
            return true;
        };

        function expr() {
            let v = term();
            while (peek() === "+" || peek() === "-")
                v = toks[i++] === "+" ? v + term() : v - term();
            return v;
        }
        function term() {
            let v = unary();
            while (peek() === "*" || peek() === "/" || peek() === "%") {
                const op = toks[i++], r = unary();
                v = op === "*" ? v * r : op === "/" ? v / r : v % r;
            }
            return v;
        }
        function unary() {
            if (take("-"))
                return -unary();
            if (take("+"))
                return unary();
            const b = atom();
            return take("^") ? Math.pow(b, unary()) : b;
        }
        function atom() {
            const t = toks[i++];
            if (t === undefined)
                fail();
            if (/^[\d.]/.test(t))
                return parseFloat(t);
            if (t === "(") {
                const v = expr();
                if (!take(")"))
                    fail();
                return v;
            }
            if (root.fns.hasOwnProperty(t) && take("(")) {
                const v = root.fns[t](expr());
                if (!take(")"))
                    fail();
                return v;
            }
            if (root.consts.hasOwnProperty(t))
                return root.consts[t];
            return fail();
        }

        try {
            const v = expr();
            if (i !== toks.length || !isFinite(v))
                return "";
            return String(parseFloat(v.toPrecision(12)));
        } catch (e) {
            return "";
        }
    }
}
