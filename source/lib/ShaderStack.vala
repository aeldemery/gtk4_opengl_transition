public class Gtk4Demo.ShaderStack : Gtk.Widget {
    GenericArray<Gtk.Widget> children;
    Gsk.GLShader shader;

    uint tick_id;
    float time;
    int64 first_frame_time;
    int current;
    int next;
    bool backwards;

    [Description (nick = "Duration", blurb = "Shader Transition Duration.")]
    public float duration { get; set; default = 1f; }

    public ShaderStack (string shader_resource) {
        this.children = new GenericArray<Gtk.Widget>();
        this.current = this.next = -1;

        GLib.Bytes resource;

        try {
            resource = GLib.resources_lookup_data (shader_resource, GLib.ResourceLookupFlags.NONE);
        } catch (Error err) {
            error ("Couldn't Load Resource: %s\n", err.message);
        }

        shader = new Gsk.GLShader.from_bytes (resource);
    }
    public void add_child_widget (Gtk.Widget child) {
        children.add (child);
        child.set_parent (this);

        this.queue_resize ();
        if (this.current == -1) {
            this.current = 0;
        } else {
            child.visible = false;
        }
    }

    public void set_active_widget (int idx) {
        this.stop_transition ();
        this.current = int.min (idx, children.length);
        this.update_visible_child ();
    }

    public void transite_forward () {
        backwards = false;
        this.stop_transition ();
        this.next = (this.current + 1) % this.children.length;
        this.update_visible_child ();
        this.start_transition ();
    }

    public void transite_backward () {
        backwards = true;
        this.stop_transition ();
        this.next = (this.current + this.children.length - 1) % this.children.length;
        this.update_visible_child ();
        this.start_transition ();
    }

    protected override void dispose () {
        stop_transition ();
        for (int i = 0; i < children.length; i ++) {
            children[i].unparent();
        }
        base.dispose ();
    }

    protected override void measure (Gtk.Orientation orientation,
                                     int for_size,
                                     out int minimum,
                                     out int natural,
                                     out int minimum_baseline,
                                     out int natural_baseline) {

        minimum = 0;
        natural = 0;
        minimum_baseline = -1;
        natural_baseline = -1;
        for (int i = 0; i < children.length; i++) {
            int child_min, child_nat;
            if (children[i].visible = true) {
                children[i].measure (orientation, for_size, out child_min, out child_nat, null, null);
                minimum = int.max (minimum, child_min);
                natural = int.max (natural, child_nat);
            }
        }
    }

    protected override void size_allocate (int width, int height, int base_line) {
        var child_allocation = Gtk.Allocation ();
        child_allocation.x = 0;
        child_allocation.y = 0;
        child_allocation.width = width;
        child_allocation.height = height;

        for (int i = 0; i < children.length; i++) {
            if (children[i].visible == true) {
                children[i].allocate_size (child_allocation, -1);
            }
        }
    }

    protected override void snapshot (Gtk.Snapshot snapshot) {
        var width = this.get_width ();
        var height = this.get_height ();

        var current_widget = children[this.current];

        if (this.next == -1) {
            this.snapshot_child (current_widget, snapshot);
        } else {
            var renderer = this.get_native ().get_renderer ();

            var progress = this.time / this.duration;
            var next_widget = children[this.next];

            if (this.backwards = true) {
                var tmp = next_widget;
                next_widget = current_widget;
                current_widget = tmp;
                progress = 1 - progress;
            }

            try {
                var compiled_ok = this.shader.compile (renderer);
                if (compiled_ok = true) {
                    snapshot.push_gl_shader (this.shader,
                                             { { 0, 0 }, { width, height } },
                                             this.shader.format_args ("progress", progress));

                    this.snapshot_child (current_widget, snapshot);
                    snapshot.gl_shader_pop_texture (); /* current child */
                    this.snapshot_child (next_widget, snapshot);
                    snapshot.gl_shader_pop_texture (); /* next child */
                    snapshot.pop ();
                } else {
                    this.snapshot_child (current_widget, snapshot);
                }
            } catch (Error err) {
                error ("Failed to compile shader: %s\n", err.message);
            }
        }
    }

    void update_visible_child () {
        for (int i = 0; i < children.length; i++) {
            children[i].set_visible (i == this.current || i == this.next);
        }
    }

    bool transition_cb (Gtk.Widget widget, Gdk.FrameClock clock) {
        var frame_time = clock.get_frame_time ();

        if (this.first_frame_time == 0) {
            this.first_frame_time = frame_time;
        }

        this.time = (frame_time - this.first_frame_time) / 1000000f;

        this.queue_draw ();

        if (this.time >= this.duration) {
            this.current = this.next;
            this.next = -1;
            update_visible_child ();
            return Source.REMOVE;
        } else {
            return Source.CONTINUE;
        }
    }

    void start_transition () {
        this.first_frame_time = 0;
        this.tick_id = this.add_tick_callback (transition_cb);
    }

    void stop_transition () {
        if (this.tick_id != 0) {
            this.remove_tick_callback (this.tick_id);
            this.tick_id = 0;
        }

        if (this.next != -1) {
            this.current = this.next;
        }

        this.next = -1;
        update_visible_child ();
    }
}