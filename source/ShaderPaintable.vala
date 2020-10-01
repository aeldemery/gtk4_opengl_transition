public class Gtk4Demo.ShaderPaintable : Object, Gdk.Paintable {
    int64 start_time;

    // Properties

    /**
     * Sets the @shader that the paintable will use
     * to create pixels. The shader must not require
     * input textures.
     */
    [Description (nick = "Shader", blurb = "The Shader to use in paintable.")]
    Gsk.GLShader _shader;
    public Gsk.GLShader shader {
        get {
            return _shader;
        }
        set {
            _shader = value;
            if (_shader.get_n_textures () > 0) {
                critical ("The shader must not require input textures.\n");
            }
            this.invalidate_contents ();
        }
    }

    /**
     * Sets the uniform data block that will be passed to the
     * shader when rendering. The @args will typically
     * be produced by a #GskUniformDataBuilder.
     */
    [Description (nick = "Arguments", blurb = "The Uniform Arguments.")]
    GLib.Bytes _args;
    public GLib.Bytes args {
        get {
            return _args;
        }
        set {
            if (value.get_size () != this.shader.get_args_size ()) {
                critical ("Arguments size must be the same size of Shader args.\n");
            }
            _args = value;
            this.invalidate_contents ();
        }
    }

    /**
     * Constructor ShaderPaintable:
     * @shader: the shader to use
     * @data: (nullable): uniform data
     *
     * Creates a paintable that uses the @shader to create
     * pixels. The shader must not require input textures.
     * If @data is %NULL, all uniform values are set to zero.
     */
    public ShaderPaintable (Gsk.GLShader shader, GLib.Bytes ? args = null) {
        if (args == null) {
            this.shader = shader;
            var size = shader.get_args_size ();
            var data = new uint8[size];
            this.args = new GLib.Bytes.take (data);
        } else {
            this.shader = shader;
            this.args = args;
        }
    }

    /**
     * update_time:
     * @time_idx: the index of the uniform for time in seconds as float
     * @frame_time: the current frame time, as returned by #GdkFrameClock
     *
     * This function is a convenience wrapper for
     * set_args() that leaves all uniform values unchanged,
     * except for the uniform with index @time_idx,
     * which will be set to the elapsed time in seconds,
     * since the first call to this function.
     *
     * This function is usually called from a #GtkTickCallback.
     */
    public void update_time (int time_idx, int64 frame_time) {
        if (this.start_time == 0) {
            this.start_time = frame_time;
        }

        var time = (frame_time - this.start_time) / (float) GLib.TimeSpan.SECOND;

        var builder = new Gsk.ShaderArgsBuilder (this.shader, this.args);
        builder.set_float (time_idx, time);

        var args = builder.to_args ();
        this.args = args;
    }

    protected void snapshot (Gdk.Snapshot snapshot, double width, double height) {
        var gtk_snapshot = (Gtk.Snapshot)snapshot;
        gtk_snapshot.push_gl_shader (this.shader, { { 0, 0 }, { (float) width, (float) height } }, this.args);
        gtk_snapshot.pop ();
    }
}