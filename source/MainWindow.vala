public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application app) {
        Object (application: app);
        this.default_height = 600;
        this.default_width = 800;

        var shader = new Gsk.GLShader.from_resource ("/github/aeldemery/gtk4_opengl_transition/background.glsl");
        var paintable = new ShaderPaintable (shader);
        var picture = new Gtk.Picture.for_paintable (paintable);
        picture.add_tick_callback ((widget, clock) => {
            var pic = (Gtk.Picture)widget;
            var paint = pic.get_paintable ();
            var shader_paintable = (ShaderPaintable) paintable;
            var time = clock.get_frame_time ();
            shader_paintable.update_time (0, time);
            return GLib.Source.CONTINUE;
        });
        this.set_child (picture);
    }

    bool update_frame_cb (Gtk.Widget widget, Gdk.FrameClock clock) {
        var pic = (Gtk.Picture)widget;
        var paintable = pic.get_paintable ();
        var shader_paintable = (ShaderPaintable) paintable;
        var time = clock.get_frame_time ();
        shader_paintable.update_time (0, time);
        return GLib.Source.CONTINUE;
    }
}