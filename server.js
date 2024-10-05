const { exec, spawn } = require('child_process');
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Directories for server configuration
const serverPropertiesPath = path.join(__dirname, '../server.properties');
const pluginsDir = path.join(__dirname, '../plugins');
const phpExecutable = 'php-cgi';

// Setup Express app
const app = express();
app.use(express.static(path.join(__dirname, 'static')));

// Middleware to serve PHP files
app.get('*.php', (req, res) => {
    const phpFilePath = path.join(__dirname, 'static', req.path);
    exec(`${phpExecutable} ${phpFilePath}`, (err, stdout, stderr) => {
        if (err) {
            console.error(`Error executing PHP: ${stderr}`);
            res.status(500).send('Internal Server Error.');
            return;
        }
        res.send(stdout);
    });
});

// Function to restart the Minecraft server
function restartMinecraftServer() {
    console.log('Restarting Minecraft server...');
    
    // Spawn Java process to start the Minecraft server
    const serverProcess = spawn('java', ['-Xmx1024M', '-Xms1024M', '-jar', 'paper-1.21.1-110.jar', 'nogui'], {
        cwd: path.join(__dirname, '..')  // Navigate to Minecraft server directory
    });

    serverProcess.stdout.on('data', (data) => {
        console.log(`Minecraft Server: ${data}`);
    });

    serverProcess.stderr.on('data', (data) => {
        console.error(`Error: ${data}`);
    });

    serverProcess.on('close', (code) => {
        console.log(`Minecraft server exited with code ${code}`);
    });
}

// Automatically restart the Minecraft server when the system starts
restartMinecraftServer();

// Watch for changes to server.properties and restart server when modified
fs.watchFile(serverPropertiesPath, (curr, prev) => {
    console.log('server.properties file modified, restarting server...');
    restartMinecraftServer();
});

// Handle plugin upload
const upload = multer({ dest: pluginsDir });

app.post('/upload-plugin', upload.single('plugin'), (req, res) => {
    const file = req.file;
    if (file) {
        const destPath = path.join(pluginsDir, file.originalname);
        fs.renameSync(file.path, destPath);
        res.send('Plugin uploaded successfully.');
    } else {
        res.status(400).send('Plugin upload failed.');
    }
});

// Start the Express server on port 3000
app.listen(3000, () => {
    console.log('Minecraft server control panel running on port 3000.');

    open('http://localhost:3000/index.php');
});

