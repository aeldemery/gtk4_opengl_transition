public class Gtk4Demo.WindStack : ShaderStack {
    public WindStack () {
        base ("/github/aeldemery/gtk4_opengl_transition/transition-wind.glsl");

        var shader = new Gsk.GLShader.from_resource ("/github/aeldemery/gtk4_opengl_transition/cogs2.glsl");
        var cogs = new ShaderPaintable (shader);
        var pic = new Gtk.Picture ();
        pic.set_paintable (cogs);
        pic.add_tick_callback (update_paintable);
        pic.can_shrink = true;
        this.add_child_widget (pic);

        var rose = new Gtk.Picture.for_resource ("/github/aeldemery/gtk4_opengl_transition/portland-rose.jpg");
        this.add_child_widget (rose);
    }

    bool update_paintable (Gtk.Widget widget, Gdk.FrameClock clock) {
        var pic = (Gtk.Picture)widget;
        var paintable = pic.get_paintable ();
        var shader_paintable = (ShaderPaintable) paintable;
        var time = clock.get_frame_time ();
        shader_paintable.update_time (0, time);
        return GLib.Source.CONTINUE;
    }
}