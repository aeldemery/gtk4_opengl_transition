public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    Gtk.Picture picture;
    ShaderPaintable paintable;
    Gsk.GLShader shader;

    public MainWindow (Gtk.Application app) {
        Object (application: app);
        this.default_height = 600;
        this.default_width = 800;

        shader = new Gsk.GLShader.from_resource ("/github/aeldemery/gtk4_opengl_transition/background.glsl");
        paintable = new ShaderPaintable (shader);
        picture = new Gtk.Picture.for_paintable (paintable);
        picture.add_tick_callback (update_frame_cb);
        this.set_child (picture);
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