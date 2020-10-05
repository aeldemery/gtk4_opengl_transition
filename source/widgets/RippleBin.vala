public class Gtk4Demo.RippleBin : ShaderBin {
    public RippleBin (Gtk.Widget child) {
        base (child, "/github/aeldemery/gtk4_opengl_transition/ripple.glsl", Gtk.StateFlags.PRELIGHT, 20);
    }
}