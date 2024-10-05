<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Minecraft Server Control Panel</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            color: #333;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        h1 {
            text-align: center;
        }
        textarea {
            width: 100%;
            height: 300px;
            margin-bottom: 10px;
        }
        input[type="file"] {
            display: block;
            margin-bottom: 10px;
        }
        .warning {
            color: red;
            font-weight: bold;
        }
        button {
            padding: 10px 20px;
            background-color: #007BFF;
            color: white;
            border: none;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Minecraft Server Control Panel</h1>

        <h2>Edit server.properties</h2>
        <div class="warning">Warning: Modifying server ports or sensitive settings can cause the server to malfunction or stop.</div>

        <form method="post">
            <textarea name="serverProperties" id="serverProperties"><?php
                // Load the server.properties file
                $filePath = '../server.properties';
                if (file_exists($filePath)) {
                    echo htmlspecialchars(file_get_contents($filePath));
                } else {
                    echo 'server.properties file not found!';
                }
            ?></textarea>
            <button type="submit">Save Changes</button>
        </form>

        <?php
        // Save the server.properties file if POST request is made
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $newContent = $_POST['serverProperties'] ?? '';
            if ($newContent !== '') {
                file_put_contents($filePath, $newContent);
                echo "<p>Changes saved! Restarting server...</p>";
                // Send request to Node.js to restart the server
                exec("curl http://localhost:3000/restart-server");
            } else {
                echo "<p>No content provided!</p>";
            }
        }
        ?>

        <h2>Upload a Plugin (.jar)</h2>
        <form action="/upload-plugin" method="post" enctype="multipart/form-data">
            <input type="file" name="plugin" accept=".jar">
            <button type="submit">Upload Plugin</button>
        </form>

        <p>Example plugins available at: <a href="https://hangar.papermc.io" target="_blank">https://hangar.papermc.io</a></p>
    </div>
</body>
</html>
