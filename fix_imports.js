const fs = require('fs');
let lines = fs.readFileSync('apps/user-app/lib/screens/home_screen.dart', 'utf8').split('\n');

// Find the bad imports and remove them
let newLines = [];
let foundImports = false;
for (let line of lines) {
    if (line.includes(\"import '../models/product_model.dart';\") || line.includes(\"import '../services/product_service.dart';\")) {
        if (!foundImports && line.trim().startsWith('import')) {
            // These might be the ones I added in the middle
            if (newLines.length > 20) {
                // Yes, skip them
                continue;
            }
        }
    }
    newLines.push(line);
}

// Add them at the top (after other imports)
let finalLines = [];
let added = false;
for (let i = 0; i < newLines.length; i++) {
    finalLines.push(newLines[i]);
    if (!added && newLines[i].startsWith('import ') && (i + 1 == newLines.length || !newLines[i+1].startsWith('import '))) {
        finalLines.push(\"import '../models/product_model.dart';\");
        finalLines.push(\"import '../services/product_service.dart';\");
        added = true;
    }
}

fs.writeFileSync('apps/user-app/lib/screens/home_screen.dart', finalLines.join('\n'), 'utf8');
console.log('Fixed imports');
