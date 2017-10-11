j$ = jQuery.noConflict();

j$(".sortCode").keyup(function (event) {
    var target = event.srcElement;
    var maxLength = parseInt(target.attributes['maxlength'].value, 10);
    var currentLength = target.value.length;
    if (event.which != 9 && event.which != 32 && currentLength >= maxLength) {
        var next = j$(this).next();
        next.focus();
        next.select();
    }
});

j$(".accountNumber").keydown(function (event) {
    if (event.keyCode == 32) {
        return false;
    }
});

function hideUkDirectDebitInfoHelpers() {
    setCss("beginDateInfoIcon", "display", "none");
    setCss("scheduleDateInfoIcon", "display", "none");
    setCss("frequencyInfoIcon", "display", "none");
    setCss("amountInfoIcon", "display", "none");
}

function hideNonUkDirectDebitInfoHelpers() {
    setCss("beginDateFrequencyIcon", "display", "none");
    setCss("scheduleDateMonthlyIcon", "display", "none");
}

function hoverdiv(e, divid) {
    var left  = e.clientX  + "px";
    var top  = e.clientY  + "px";

    var div = document.getElementById(divid);

    div.style.left = left;
    div.style.top = top;

    j$("#" + divid).toggle();
    return false;
}

function hideCancellationReason() {
    var id = "cancellationReasonContainer";
    setCss(id, "display", "none");
    j$("#" + id + " :input").each(function(i, obj) {
        setProperty(obj.id, "disabled", true);
    });
}

function showCancellationReason() {
    var id = "cancellationReasonContainer";
    setCss(id, "display", "block");
    j$("#" + id + " :input").each(function(i, obj) {
        setProperty(obj.id, "disabled", false);
    });
}

function showSection(sectionId) {
    setCss(sectionId, "display", "flex");
    j$("#" + sectionId + " :input").each(function(i, obj) {
        setProperty(obj.id, "disabled", false);
    });
}

function hideSection(sectionId) {
    setCss(sectionId, "display", "none");
    j$("#" + sectionId + " :input").each(function(i, obj) {
        setProperty(obj.id, "disabled", true);
    });
}

function setReadonly(id) {
    var element = document.getElementById(id);
    j$(element).prop("readonly", true);
    j$(element).prop("tabindex", '-1');
}

function setProperty(id, property, value) {
    var element = document.getElementById(id);
    j$(element).prop(property, value);
}

function setHtml(id, value) {
    var element = document.getElementById(id);
    j$(element).html(value);
}

function setCss(id, field, value) {
    var element = document.getElementById(id);
    j$(element).css(field, value);
}

function onSubmitClicked() {
    submitClicked = true;
}

function showRoutingInfo() { 
    j$("#routingInfoContainer").dialog("open");
}

function showAddNewAllocation() { 
    j$("#addNewAllocationContainer").dialog("open");
}

function changeFrequency(dropDown) {
    j$(".hiddenFrequency").val(dropDown.value);
}

function changeScheduleDate(dropDown) {
    j$(".hiddenScheduleDate").val(dropDown.value);
}

function changeStatus(dropDown) {
    j$(".hiddenStatus").val(dropDown.value);
}
