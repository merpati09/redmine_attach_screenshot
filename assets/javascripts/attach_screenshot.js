//var screenshotFieldCount = 1;

function hideAttachScreen() {
    document.getElementById('attach_applet').style.display = 'none';
    document.getElementById('attach_applet').innerHTML = '';
}
function deleteAttachScreen(fileId) {
    p.removeChild(document.getElementById(fileId + "_screenshot"));
}
