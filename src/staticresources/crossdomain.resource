(function ($) { var g, d, j = 1, a, b = this, f = !1, h = "postMessage", e = "addEventListener", c, i = b[h] && !$.browser.opera; $[h] = function (k, l, m) { if (!l) { return } k = typeof k === "string" ? k : $.param(k); m = m || parent; if (i) { m[h](k, l.replace(/([^:]+:\/\/[^\/]+).*/, "$1")) } else { if (l) { m.location = l.replace(/#.*$/, "") + "#" + (+new Date) + (j++) + "&" + k } } }; $.receiveMessage = c = function (l, m, k) { if (i) { if (l) { a && c(); a = function (n) { if ((typeof m === "string" && n.origin !== m) || ($.isFunction(m) && m(n.origin) === f)) { return f } l(n) } } if (b[e]) { b[l ? e : "removeEventListener"]("message", a, f) } else { b[l ? "attachEvent" : "detachEvent"]("onmessage", a) } } else { g && clearInterval(g); g = null; if (l) { k = typeof m === "number" ? m : typeof k === "number" ? k : 100; g = setInterval(function () { var o = document.location.hash, n = /^#?\d+&/; if (o !== d && n.test(o)) { d = o; l({ data: o.replace(n, "") }) } }, k) } } } })(jQuery);

jQuery.fn.loadCauseViewForm = function (options) {
    var options = $.extend({ src: '', applyQueryStrings: false, api: 'https://api.causeview.com', frame_height:"250px" }, options);
    var origin = location.protocol + '//' + location.host + location.pathname;
    var queryString = '', frameSrc = options.src;
    if (options.applyQueryStrings && location.search) {
        queryString = location.search.replace('?', '');
        if (frameSrc.indexOf("?") > 0)
            frameSrc += "&" + queryString;
        else
            frameSrc += "?" + queryString;

        frameSrc += "&";
    }
    else {
        if (frameSrc.indexOf("?") > 0)
            frameSrc += "&";
        else
            frameSrc += "?";
    }

    frameSrc += "hostUrl=" + encodeURIComponent(origin);

    iframe = $('<iframe src="' + frameSrc + '" width="100%" height="' + options.frame_height + '" scrolling="no" frameborder="0"></iframe>').appendTo($(this));
    $.receiveMessage(function(e) {
        if (e.data.indexOf('pheight=') >= 0) {
            var h = Number(e.data.replace('pheight=', ''));
            if (!isNaN(h) && h > 0) { if (h < 150) h = 150; iframe.height(h); }
        }
        if (e.data.indexOf("predirect") >= 0) {
            var redirect = e.data.replace(/.*predirect=(\S+)(?:&|$)/, '$1');
            top.window.location = decodeURIComponent(redirect);
        }
    }, options.api);

    return false;
}

 
 
