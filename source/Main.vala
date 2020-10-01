int main (string[] args) {
    var app = new Gtk4Demo.OpenGLTransitionApp();
    return app.run (args);
}

public class Gtk4Demo.OpenGLTransitionApp : Gtk.Application {
    public OpenGLTransitionApp () {
        Object (application_id: "github.aeldemery.gtk4_opengl_transition",
                flags: GLib.ApplicationFlags.FLAGS_NONE
            );
    }

    protected override void activate () {
        var main_win = this.active_window;
        if (main_win == null) {
            main_win = new MainWindow (this);
        }
        main_win.present ();
    }
}