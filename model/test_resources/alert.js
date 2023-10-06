"use strict";

(() => {
    alert("This HTML file only for testing purpose in oghref only");

    var ref = document.referrer;

    if (ref != "") {
        location.replace(ref);
    } else if (history.length <= 1) {
        close();
    } else {
        history.back();
    }
})();