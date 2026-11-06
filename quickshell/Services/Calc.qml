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

    // Returns the result as a string, or "" if the input isn't a valid expression.
    function evaluate(input) {
        const toks = input.toLowerCase().replace(/,/g, ".").match(/\d+\.?\d*|\.\d+|[a-z]+|[-+*\/%^()]|\S/g) ?? [];
        let i = 0;
        const fail = () => { throw new Error("bad"); };
        const peek = () => toks[i];
        const take = t => (toks[i] === t ? (i++, true) : false);

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
