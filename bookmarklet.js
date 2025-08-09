// QuickCapture Bookmarklet
// To use: Copy the minified version below and save as a bookmark in your browser

// Full readable version:
javascript:(function(){
    const data = {
        url: window.location.href,
        title: document.title,
        site: window.location.hostname
    };
    window.open(
        'https://quickcapture-frontend-a30jgui1y-densign01s-projects.vercel.app?data=' + encodeURIComponent(JSON.stringify(data)),
        'QuickCapture',
        'width=520,height=700,scrollbars=yes,resizable=yes'
    );
})();

// Minified version (copy this as your bookmark URL):
// javascript:(function(){const data={url:window.location.href,title:document.title,site:window.location.hostname};window.open('https://quickcapture-frontend-a30jgui1y-densign01s-projects.vercel.app?data='+encodeURIComponent(JSON.stringify(data)),'QuickCapture','width=520,height=700,scrollbars=yes,resizable=yes');})();