# Tray icon for the ESET kill switch in modules/eset.nix: shows whether the
# suite is protecting, degraded or off, and toggles it through pkexec.

import subprocess
import sys

from PyQt6.QtCore import QProcess, QTimer
from PyQt6.QtGui import QIcon
from PyQt6.QtWidgets import QApplication, QMenu, QSystemTrayIcon

ESET = "@eset@"
PKEXEC = "/run/wrappers/bin/pkexec"

# Keys printed by `eset status`, in menu order.
COMPONENTS = {
    "efs": "Server Security",
    "eraagent": "Management Agent",
    "eset-cron": "Scheduled scans",
    "eset_rtp": "Real-time module",
}
STATES = {
    "protected": ("security-high", "ESET: protected"),
    "degraded": ("security-medium", "ESET: not fully running"),
    "off": ("security-low", "ESET: off"),
}


def read_status():
    out = subprocess.run([ESET, "status"], capture_output=True, text=True).stdout
    return dict(line.split(None, 1) for line in out.splitlines() if line.strip())


class Tray(QSystemTrayIcon):
    def __init__(self):
        super().__init__()
        self.busy = False
        self.switch_on = True

        self.menu = QMenu()
        self.header = self.menu.addAction("")
        self.header.setEnabled(False)
        self.details = {}
        for key in COMPONENTS:
            self.details[key] = self.menu.addAction("")
            self.details[key].setEnabled(False)
        self.menu.addSeparator()
        self.toggle = self.menu.addAction("")
        self.toggle.triggered.connect(self.on_toggle)
        self.setContextMenu(self.menu)

        self.proc = QProcess(self)
        self.proc.finished.connect(self.on_finished)

        self.timer = QTimer(self)
        self.timer.timeout.connect(self.refresh)
        self.timer.start(5000)
        self.refresh()
        self.show()

    def refresh(self):
        status = read_status()
        self.switch_on = status.get("switch") != "off"
        down = [name for key, name in COMPONENTS.items() if status.get(key) not in ("active", "loaded")]
        if not self.switch_on:
            state = "off"
        elif down:
            state = "degraded"
        else:
            state = "protected"

        icon, text = STATES[state]
        self.setIcon(QIcon.fromTheme(icon))
        self.setToolTip(text + ("\nNot running: " + ", ".join(down) if state == "degraded" else ""))
        self.header.setText(text)
        for key, name in COMPONENTS.items():
            self.details[key].setText(f"{name}: {status.get(key, 'unknown')}")
        if not self.busy:
            self.toggle.setText("Turn ESET off" if self.switch_on else "Turn ESET on")
            self.toggle.setEnabled(True)

    def on_toggle(self):
        self.busy = True
        self.toggle.setEnabled(False)
        self.toggle.setText("Turning ESET off…" if self.switch_on else "Turning ESET on…")
        self.proc.start(PKEXEC, [ESET, "off" if self.switch_on else "on"])

    def on_finished(self, code, _status):
        self.busy = False
        # 126: the password prompt was dismissed.
        if code not in (0, 126):
            error = bytes(self.proc.readAllStandardError()).decode(errors="replace").strip()
            self.showMessage("ESET", error.splitlines()[-1] if error else f"eset exited with {code}",
                             QSystemTrayIcon.MessageIcon.Warning)
        self.refresh()


def main():
    app = QApplication(sys.argv)
    app.setQuitOnLastWindowClosed(False)
    # Noctalia may not be up yet at login; systemd restarts us.
    if not QSystemTrayIcon.isSystemTrayAvailable():
        sys.exit(1)
    tray = Tray()  # noqa: F841
    sys.exit(app.exec())


main()
