const fs = require('fs');
const path = require('path');
const rootDir = 'c:/Users/007/Desktop/apple'.replace(/\//g, path.sep);

function walk(dir, callback) {
    if (!fs.existsSync(dir)) return;
    fs.readdirSync(dir).forEach(f => {
        if (f === '.git' || f === 'node_modules') return;
        let dirPath = path.join(dir, f);
        try {
            let isDirectory = fs.statSync(dirPath).isDirectory();
            isDirectory ? walk(dirPath, callback) : callback(dirPath);
        } catch(e) {}
    });
}

walk(rootDir, function(filePath) {
    if (filePath.endsWith('.html') || filePath.endsWith('.js')) {
        let content = fs.readFileSync(filePath, 'utf8');
        let newContent = content;
        
        let relativeToRoot = path.relative(path.dirname(filePath), rootDir).replace(/\\/g, '/');
        let rootIndex = relativeToRoot ? relativeToRoot + '/index.html' : 'index.html';
        
        // Replace all href="https://*.apple.com*" to href="../index.html"
        newContent = newContent.replace(/href=[\"']https?:\/\/(www\.)?apple\.com[^\"]*?[\"']/gi, 'href=\"' + rootIndex + '\"');
        newContent = newContent.replace(/href=[\"']https?:\/\/store\.apple\.com[^\"]*?[\"']/gi, 'href=\"' + rootIndex + '\"');
        newContent = newContent.replace(/href=[\"']https?:\/\/support\.apple\.com[^\"]*?[\"']/gi, 'href=\"' + rootIndex + '\"');
        
        // Replace JSON keys for navigation links (the script block has URLs inside it)
        newContent = newContent.replace(/\"https?:\/\/(www\.)?apple\.com[^\"]*?\"/gi, '\"' + rootIndex + '\"');
        
        if (content !== newContent) {
            fs.writeFileSync(filePath, newContent, 'utf8');
            console.log('Fixed ' + filePath);
        }
    }
});
