public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    Gtk.Picture picture;
    ShaderPaintable paintable;
    Gsk.GLShader shader;
    Gtk.Grid outer_grid;

    public MainWindow (Gtk.Application app) {
        Object (application: app);
        this.default_height = 600;
        this.default_width = 800;

        outer_grid = new Gtk.Grid ();
        outer_grid.hexpand = outer_grid.vexpand = true;

        shader = new Gsk.GLShader.from_resource ("/github/aeldemery/gtk4_opengl_transition/background.glsl");
        paintable = new ShaderPaintable (shader);
        picture = new Gtk.Picture.for_paintable (paintable);
        picture.add_tick_callback (update_frame_cb);

        var fixed = new Gtk.Fixed ();
        fixed.set_size_request (120, 90);

        var button = new Gtk.Button.with_label ("Test");
        var ripple = new RippleBin (button);

        //fixed.put (ripple, 40, 40);

        var wind = new WindStack ();
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        var next = new Gtk.Button.with_label ("Next");
        next.clicked.connect (() => {
            wind.transite_forward ();
        });
        box.append (wind);
        box.append (next);

        // outer_grid.attach (picture, 0, 0);
        this.set_child (box);
    }

    static bool update_frame_cb (Gtk.Widget widget, Gdk.FrameClock clock) {
        var pic = (Gtk.Picture)widget;
        var paintable = pic.get_paintable ();
        var shader_paintable = (ShaderPaintable) paintable;
        var time = clock.get_frame_time ();
        shader_paintable.update_time (0, time);
        return GLib.Source.CONTINUE;
    }
}