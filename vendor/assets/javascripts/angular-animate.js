/*
 AngularJS v1.2.10-build.2164+sha.8b395ff
 (c) 2010-2014 Google, Inc. http://angularjs.org
 License: MIT
*/
(function(H, f, s) {
    'use strict';
    f.module("ngAnimate", ["ng"]).factory("$$animateReflow", ["$window", "$timeout", function(f, D) {
        var c = f.requestAnimationFrame || f.webkitRequestAnimationFrame || function(c) {
                return D(c, 10, !1)
            }, x = f.cancelAnimationFrame || f.webkitCancelAnimationFrame || function(c) {
                return D.cancel(c)
            };
        return function(k) {
            var f = c(k);
            return function() {
                x(f)
            }
        }
    }]).config(["$provide", "$animateProvider", function(S, D) {
        function c(c) {
            for (var f = 0; f < c.length; f++) {
                var k = c[f];
                if (k.nodeType == Y) return k
            }
        }
        var x = f.noop,
            k = f.forEach,
            ba = D.$$selectors,
            Y = 1,
            l = "$$ngAnimateState",
            L = "ng-animate",
            n = {
                running: !0
            };
        S.decorator("$animate", ["$delegate", "$injector", "$sniffer", "$rootElement", "$timeout", "$rootScope", "$document", function(E, H, s, I, u, r, O) {
            function J(a) {
                if (a) {
                    var h = [],
                        e = {};
                    a = a.substr(1).split(".");
                    (s.transitions || s.animations) && a.push("");
                    for (var b = 0; b < a.length; b++) {
                        var g = a[b],
                            c = ba[g];
                        c && !e[g] && (h.push(H.get(c)), e[g] = !0)
                    }
                    return h
                }
            }
            function p(a, h, e, b, g, f, t) {
                function n(a) {
                    z();
                    if (!0 === a) q();
                    else {
                        if (a = e.data(l)) a.done = q, e.data(l,
                        a);
                        s(w, "after", q)
                    }
                }
                function s(b, c, g) {
                    "after" == c ? r() : F();
                    var f = c + "End";
                    k(b, function(k, d) {
                        var G = function() {
                            a: {
                                var G = c + "Complete",
                                    a = b[d];
                                a[G] = !0;
                                (a[f] || x)();
                                for (a = 0; a < b.length; a++) if (!b[a][G]) break a;
                                g()
                            }
                        };
                        "before" != c || "enter" != a && "move" != a ? k[c] ? k[f] = B ? k[c](e, h, G) : k[c](e, G) : G() : G()
                    })
                }
                function E(b) {
                    e.triggerHandler("$animate:" + b, {
                        event: a,
                        className: h
                    })
                }
                function F() {
                    u(function() {
                        E("before")
                    }, 0, !1)
                }
                function r() {
                    u(function() {
                        E("after")
                    }, 0, !1)
                }
                function z() {
                    z.hasBeenRun || (z.hasBeenRun = !0, f())
                }
                function q() {
                    if (!q.hasBeenRun) {
                        q.hasBeenRun = !0;
                        var a = e.data(l);
                        a && (B ? C(e) : (a.closeAnimationTimeout = u(function() {
                            C(e)
                        }, 0, !1), e.data(l, a)));
                        t && u(t, 0, !1)
                    }
                }
                var A, v, p = c(e);
                p && (A = p.className, v = A + " " + h);
                if (p && M(v)) {
                    v = (" " + v).replace(/\s+/g, ".");
                    b || (b = g ? g.parent() : e.parent());
                    v = J(v);
                    var B = "addClass" == a || "removeClass" == a;
                    g = e.data(l) || {};
                    if (ca(e, b) || 0 === v.length) z(), F(), r(), q();
                    else {
                        var w = [];
                        B && (g.disabled || g.running && g.structural) || k(v, function(b) {
                            if (!b.allowCancel || b.allowCancel(e, a, h)) {
                                var c = b[a];
                                "leave" == a ? (b = c, c = null) : b = b["before" + a.charAt(0).toUpperCase() + a.substr(1)];
                                w.push({
                                    before: b,
                                    after: c
                                })
                            }
                        });
                        0 === w.length ? (z(), F(), r(), t && u(t, 0, !1)) : (b = " " + A + " ", g.running && (u.cancel(g.closeAnimationTimeout), C(e), K(g.animations), v = (A = B && !g.structural) && g.className == h && a != g.event, g.beforeComplete || v ? (g.done || x)(!0) : A && (b = "removeClass" == g.event ? b.replace(" " + g.className + " ", " ") : b + g.className + " ")), A = " " + h + " ", "addClass" == a && 0 <= b.indexOf(A) || "removeClass" == a && -1 == b.indexOf(A) ? (z(), F(), r(), t && u(t, 0, !1)) : (e.addClass(L), e.data(l, {
                            running: !0,
                            event: a,
                            className: h,
                            structural: !B,
                            animations: w,
                            done: n
                        }), s(w, "before", n)))
                    }
                } else z(), F(), r(), q()
            }
            function R(a) {
                a = c(a);
                k(a.querySelectorAll("." + L), function(a) {
                    a = f.element(a);
                    var e = a.data(l);
                    e && (K(e.animations), C(a))
                })
            }
            function K(a) {
                k(a, function(a) {
                    a.beforeComplete || (a.beforeEnd || x)(!0);
                    a.afterComplete || (a.afterEnd || x)(!0)
                })
            }
            function C(a) {
                c(a) == c(I) ? n.disabled || (n.running = !1, n.structural = !1) : (a.removeClass(L), a.removeData(l))
            }
            function ca(a, h) {
                if (n.disabled) return !0;
                if (c(a) == c(I)) return n.disabled || n.running;
                do {
                    if (0 === h.length) break;
                    var e = c(h) == c(I),
                        b = e ? n : h.data(l),
                        b = b && ( !! b.disabled || !! b.running);
                    if (e || b) return b;
                    if (e) break
                } while (h = h.parent());
                return !0
            }
            I.data(l, n);
            r.$$postDigest(function() {
                r.$$postDigest(function() {
                    n.running = !1
                })
            });
            var N = D.classNameFilter(),
                M = N ? function(a) {
                    return N.test(a)
                } : function() {
                    return !0
                };
            return {
                enter: function(a, c, e, b) {
                    this.enabled(!1, a);
                    E.enter(a, c, e);
                    r.$$postDigest(function() {
                        p("enter", "ng-enter", a, c, e, x, b)
                    })
                },
                leave: function(a, c) {
                    R(a);
                    this.enabled(!1, a);
                    r.$$postDigest(function() {
                        p("leave", "ng-leave",
                        a, null, null, function() {
                            E.leave(a)
                        }, c)
                    })
                },
                move: function(a, c, e, b) {
                    R(a);
                    this.enabled(!1, a);
                    E.move(a, c, e);
                    r.$$postDigest(function() {
                        p("move", "ng-move", a, c, e, x, b)
                    })
                },
                addClass: function(a, c, e) {
                    p("addClass", c, a, null, null, function() {
                        E.addClass(a, c)
                    }, e)
                },
                removeClass: function(a, c, e) {
                    p("removeClass", c, a, null, null, function() {
                        E.removeClass(a, c)
                    }, e)
                },
                enabled: function(a, c) {
                    switch (arguments.length) {
                        case 2:
                            if (a) C(c);
                            else {
                                var e = c.data(l) || {};
                                e.disabled = !0;
                                c.data(l, e)
                            }
                            break;
                        case 1:
                            n.disabled = !a;
                            break;
                        default:
                            a = !n.disabled
                    }
                    return !!a
                }
            }
        }]);
        D.register("", ["$window", "$sniffer", "$timeout", "$$animateReflow", function(n, l, D, I) {
            function u(d, a) {
                P && P();
                V.push(a);
                var y = c(d);
                d = f.element(y);
                W.push(d);
                var y = d.data(q),
                    b = y.stagger,
                    b = y.itemIndex * (Math.max(b.animationDelay, b.transitionDelay) || 0);
                Q = Math.max(Q, (b + (y.maxDelay + y.maxDuration) * v) * aa);
                y.animationCount = B;
                P = I(function() {
                    k(V, function(d) {
                        d()
                    });
                    var d = [],
                        a = B;
                    k(W, function(a) {
                        d.push(a)
                    });
                    D(function() {
                        r(d, a);
                        d = null
                    }, Q, !1);
                    V = [];
                    W = [];
                    P = null;
                    w = {};
                    Q = 0;
                    B++
                })
            }
            function r(d, a) {
                k(d, function(d) {
                    (d = d.data(q)) && d.animationCount == a && (d.closeAnimationFn || x)()
                })
            }
            function O(d, a) {
                var c = a ? w[a] : null;
                if (!c) {
                    var b = 0,
                        e = 0,
                        m = 0,
                        f = 0,
                        h, q, l, r;
                    k(d, function(d) {
                        if (d.nodeType == Y) {
                            d = n.getComputedStyle(d) || {};
                            l = d[g + $];
                            b = Math.max(J(l), b);
                            r = d[g + X];
                            h = d[g + F];
                            e = Math.max(J(h), e);
                            q = d[t + F];
                            f = Math.max(J(q), f);
                            var a = J(d[t + $]);
                            0 < a && (a *= parseInt(d[t + S], 10) || 1);
                            m = Math.max(a, m)
                        }
                    });
                    c = {
                        total: 0,
                        transitionPropertyStyle: r,
                        transitionDurationStyle: l,
                        transitionDelayStyle: h,
                        transitionDelay: e,
                        transitionDuration: b,
                        animationDelayStyle: q,
                        animationDelay: f,
                        animationDuration: m
                    };
                    a && (w[a] = c)
                }
                return c
            }
            function J(d) {
                var a = 0;
                d = f.isString(d) ? d.split(/\s*,\s*/) : [];
                k(d, function(d) {
                    a = Math.max(parseFloat(d) || 0, a)
                });
                return a
            }
            function p(d) {
                var a = d.parent(),
                    b = a.data(z);
                b || (a.data(z, ++Z), b = Z);
                return b + "-" + c(d).className
            }
            function R(d, a, b) {
                var e = p(d),
                    f = e + " " + a,
                    m = {}, h = w[f] ? ++w[f].total : 0;
                if (0 < h) {
                    var l = a + "-stagger",
                        m = e + " " + l;
                    (e = !w[m]) && d.addClass(l);
                    m = O(d, m);
                    e && d.removeClass(l)
                }
                b = b || function(d) {
                    return d()
                };
                d.addClass(a);
                b = b(function() {
                    return O(d, f)
                });
                l = Math.max(b.transitionDelay,
                b.animationDelay);
                e = Math.max(b.transitionDuration, b.animationDuration);
                if (0 === e) return d.removeClass(a), !1;
                var n = "";
                0 < b.transitionDuration ? c(d).style[g + X] = "none" : c(d).style[t] = "none 0s";
                k(a.split(" "), function(d, a) {
                    n += (0 < a ? " " : "") + d + "-active"
                });
                d.data(q, {
                    className: a,
                    activeClassName: n,
                    maxDuration: e,
                    maxDelay: l,
                    classes: a + " " + n,
                    timings: b,
                    stagger: m,
                    itemIndex: h
                });
                return !0
            }
            function K(d) {
                var a = g + X;
                d = c(d);
                d.style[a] && 0 < d.style[a].length && (d.style[a] = "")
            }
            function C(d) {
                var a = t;
                d = c(d);
                d.style[a] && 0 < d.style[a].length && (d.style[a] = "")
            }
            function L(a, e, y) {
                function f(b) {
                    a.off(v, g);
                    a.removeClass(r);
                    b = a;
                    b.removeClass(e);
                    b.removeData(q);
                    b = c(a);
                    for (var y in s) b.style.removeProperty(s[y])
                }
                function g(a) {
                    a.stopPropagation();
                    var d = a.originalEvent || a;
                    a = d.$manualTimeStamp || d.timeStamp || Date.now();
                    d = parseFloat(d.elapsedTime.toFixed(A));
                    Math.max(a - w, 0) >= t && d >= n && y()
                }
                var m = a.data(q),
                    h = c(a);
                if (-1 != h.className.indexOf(e) && m) {
                    var k = m.timings,
                        l = m.stagger,
                        n = m.maxDuration,
                        r = m.activeClassName,
                        t = Math.max(k.transitionDelay, k.animationDelay) * aa,
                        w = Date.now(),
                        v = U + " " + T,
                        u = m.itemIndex,
                        p = "",
                        s = [];
                    if (0 < k.transitionDuration) {
                        var x = k.transitionPropertyStyle; - 1 == x.indexOf("all") && (p += b + "transition-property: " + x + ";", p += b + "transition-duration: " + k.transitionDurationStyle + ";", s.push(b + "transition-property"), s.push(b + "transition-duration"))
                    }
                    0 < u && (0 < l.transitionDelay && 0 === l.transitionDuration && (p += b + "transition-delay: " + N(k.transitionDelayStyle, l.transitionDelay, u) + "; ", s.push(b + "transition-delay")), 0 < l.animationDelay && 0 === l.animationDuration && (p += b + "animation-delay: " + N(k.animationDelayStyle, l.animationDelay, u) + "; ", s.push(b + "animation-delay")));
                    0 < s.length && (k = h.getAttribute("style") || "", h.setAttribute("style", k + " " + p));
                    a.on(v, g);
                    a.addClass(r);
                    m.closeAnimationFn = function() {
                        f();
                        y()
                    };
                    return f
                }
                y()
            }
            function N(a, b, c) {
                var e = "";
                k(a.split(","), function(a, d) {
                    e += (0 < d ? "," : "") + (c * b + parseInt(a, 10)) + "s"
                });
                return e
            }
            function M(a, b, c) {
                if (R(a, b, c)) return function(c) {
                    c && (a.removeClass(b), a.removeData(q))
                }
            }
            function a(a, b, c) {
                if (a.data(q)) return L(a, b, c);
                a.removeClass(b);
                a.removeData(q);
                c()
            }
            function h(d, b, c) {
                var e = M(d, b);
                if (e) {
                    var f = e;
                    u(d, function() {
                        K(d);
                        C(d);
                        f = a(d, b, c)
                    });
                    return function(a) {
                        (f || x)(a)
                    }
                }
                c()
            }
            function e(a, b) {
                var c = "";
                a = f.isArray(a) ? a : a.split(/\s+/);
                k(a, function(a, d) {
                    a && 0 < a.length && (c += (0 < d ? " " : "") + a + b)
                });
                return c
            }
            var b = "",
                g, T, t, U;
            H.ontransitionend === s && H.onwebkittransitionend !== s ? (b = "-webkit-", g = "WebkitTransition", T = "webkitTransitionEnd transitionend") : (g = "transition", T = "transitionend");
            H.onanimationend === s && H.onwebkitanimationend !== s ? (b = "-webkit-", t = "WebkitAnimation", U = "webkitAnimationEnd animationend") : (t = "animation", U = "animationend");
            var $ = "Duration",
                X = "Property",
                F = "Delay",
                S = "IterationCount",
                z = "$$ngAnimateKey",
                q = "$$ngAnimateCSS3Data",
                A = 3,
                v = 1.5,
                aa = 1E3,
                B = 0,
                w = {}, Z = 0,
                V = [],
                W = [],
                P, Q = 0;
            return {
                allowCancel: function(a, b, g) {
                    var h = (a.data(q) || {}).classes;
                    if (!h || 0 <= ["enter", "leave", "move"].indexOf(b)) return !0;
                    var l = a.parent(),
                        m = f.element(c(a).cloneNode());
                    m.attr("style", "position:absolute; top:-9999px; left:-9999px");
                    m.removeAttr("id");
                    m.empty();
                    k(h.split(" "),

                    function(a) {
                        m.removeClass(a)
                    });
                    m.addClass(e(g, "addClass" == b ? "-add" : "-remove"));
                    l.append(m);
                    a = O(m);
                    m.remove();
                    return 0 < Math.max(a.transitionDuration, a.animationDuration)
                },
                enter: function(a, b) {
                    return h(a, "ng-enter", b)
                },
                leave: function(a, b) {
                    return h(a, "ng-leave", b)
                },
                move: function(a, b) {
                    return h(a, "ng-move", b)
                },
                beforeAddClass: function(a, b, c) {
                    var f = M(a, e(b, "-add"), function(c) {
                        a.addClass(b);
                        c = c();
                        a.removeClass(b);
                        return c
                    });
                    if (f) return u(a, function() {
                        K(a);
                        C(a);
                        c()
                    }), f;
                    c()
                },
                addClass: function(b, c, f) {
                    return a(b,
                    e(c, "-add"), f)
                },
                beforeRemoveClass: function(a, b, c) {
                    var f = M(a, e(b, "-remove"), function(c) {
                        var e = a.attr("class");
                        a.removeClass(b);
                        c = c();
                        a.attr("class", e);
                        return c
                    });
                    if (f) return u(a, function() {
                        K(a);
                        C(a);
                        c()
                    }), f;
                    c()
                },
                removeClass: function(b, c, f) {
                    return a(b, e(c, "-remove"), f)
                }
            }
        }])
    }])
})(window, window.angular);
//# sourceMappingURL=angular-animate.min.js.map