public class Gtk4Demo.ShaderBin : Gtk.Widget {
    class Shaderinfo {
        public Gsk.GLShader shader;
        public Gtk.StateFlags state;
        public Gtk.StateFlags state_mask;

        public float extra_border;
        public bool compiled;
        public bool compiled_ok;
    }

    Shaderinfo active_shader;
    GenericArray<Shaderinfo> shaders;

    Gtk.Widget child;

    uint tick_id;
    float time;
    double mouse_x;
    double mouse_y;
    int64 first_frame_time;

    Gtk.EventControllerMotion motion_controller;

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    public ShaderBin (Gtk.Widget child,
                      string shader_resource,
                      Gtk.StateFlags when = Gtk.StateFlags.PRELIGHT,
                      float extra_border = 0) {

        this.child = child;
        this.child.set_parent (this);

        shaders = new GenericArray<Shaderinfo>();

        GLib.Bytes resource;

        try {
            resource = GLib.resources_lookup_data (shader_resource, GLib.ResourceLookupFlags.NONE);
        } catch (Error err) {
            error ("Couldn't Load Resource: %s\n", err.message);
        }

        var info = new Shaderinfo ();

        info.shader = new Gsk.GLShader.from_bytes (resource);
        info.state = when;
        info.state_mask = when;
        info.extra_border = extra_border;
        info.compiled = false;
        info.compiled_ok = false;

        shaders.add (info);


        motion_controller = new Gtk.EventControllerMotion ();
        motion_controller.motion.connect ((controller, x, y) => {
            this.mouse_x = x;
            this.mouse_y = y;
        });
        this.add_controller (motion_controller);

        this.update_active_shader ();
    }

    protected override void snapshot (Gtk.Snapshot snapshot) {
        var width = this.get_width ();
        var height = this.get_height ();

        if (this.active_shader != null) {
            if (this.active_shader.compiled == false) {
                var renderer = this.get_native ().get_renderer ();
                this.active_shader.compiled = true;
                try {
                    this.active_shader.compiled_ok = this.active_shader.shader.compile (renderer);
                } catch (Error err) {
                    warning ("Failed to compile shader: %s\n", err.message);
                }
            }

            if (this.active_shader.compiled_ok == true) {
                var border = this.active_shader.extra_border;
                var mouse = Graphene.Vec2 ();
                mouse = mouse.init ((float) this.mouse_x + border,
                                    (float) this.mouse_y + border);

                snapshot.push_gl_shader (
                    this.active_shader.shader,
                    { { -border, -border }, { width + 2 * border, height + 2 * border } },
                    this.active_shader.shader.format_args ("u_time", this.time, "u_mouse", mouse)
                );

                this.snapshot_child (this.child, snapshot);
                snapshot.gl_shader_pop_texture ();
                snapshot.pop ();
            }
        } else {
            this.snapshot_child (this.child, snapshot);
        }
    }

    protected override void dispose () {
        child.unparent ();
        base.dispose ();
    }

    protected override void state_flags_changed (Gtk.StateFlags state) {
        update_active_shader ();
    }

    bool tick_cb (Gtk.Widget widget, Gdk.FrameClock clock) {
        var frame_time = clock.get_frame_time ();

        if (this.first_frame_time == 0) {
            this.first_frame_time = frame_time;
        }

        this.time = (frame_time - this.first_frame_time) / 1000000f;

        this.queue_draw ();

        return Source.CONTINUE;
    }

    void update_active_shader () {
        var new_state = this.get_state_flags ();
        Shaderinfo new_shader = null;

        for (int i = 0; i < shaders.length; i++) {
            if ((shaders[i].state_mask & new_state) == shaders[i].state) {
                new_shader = shaders[i];
                break;
            }
        }

        if (this.active_shader == new_shader) {
            return;
        }

        this.active_shader = new_shader;

        this.first_frame_time = 0;

        if (this.active_shader != null) {
            if (this.tick_id == 0) {
                this.tick_id = this.add_tick_callback (tick_cb);
            }
        } else {
            if (this.tick_id != 0) {
                this.remove_tick_callback (this.tick_id);
                this.tick_id = 0;
            }
        }

        this.queue_draw ();
    }
}
