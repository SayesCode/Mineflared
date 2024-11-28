import socket
from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)
PROPERTIES_FILE = "server.properties"


def is_port_in_use(port):
    """Check if a specific port is in use."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(("127.0.0.1", port)) == 0


def read_properties():
    """Reads the server.properties file and returns it as a dictionary."""
    properties = {}
    try:
        with open(PROPERTIES_FILE, "r") as file:
            for line in file:
                line = line.strip()
                if line and not line.startswith("#"):  # Ignore empty lines or comments
                    key, value = line.split("=", 1)
                    properties[key.strip()] = value.strip()
    except FileNotFoundError:
        pass  # Return an empty dictionary if the file doesn't exist
    return properties


def write_properties(updated_properties):
    """Writes updated settings back to the server.properties file."""
    with open(PROPERTIES_FILE, "w") as file:
        for key, value in updated_properties.items():
            file.write(f"{key}={value}\n")


@app.route("/", methods=["GET", "POST"])
def index():
    if is_port_in_use(25565):
        # Render a warning page if the port is in use
        return render_template("warning.html")

    if request.method == "POST":
        # Update the settings
        updated_properties = {key: request.form[key] for key in request.form}
        write_properties(updated_properties)
        return redirect(url_for("index"))

    # Read settings and send them to the page
    properties = read_properties()
    return render_template("index.html", properties=properties)


if __name__ == "__main__":
    app.run(debug=True)
