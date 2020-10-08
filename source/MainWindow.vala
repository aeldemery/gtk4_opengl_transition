public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    TransitionStack stack;
    RippleBin bin;

    Gtk.Box box;
    Gtk.Box hbox;

    Gtk.Button next;
    Gtk.Button previous;
    Gtk.Label label;

    Gtk.HeaderBar header;
    Gtk.Scale duration_scale;
    Gtk.Adjustment duration_adjustment;
    Gtk.DropDown transitions;

    Gtk.Grid background_grid;
    Gsk.GLShader background_shader;
    ShaderPaintable background_paintable;
    Gtk.Picture background_pic;

    GLib.HashTable<uint, string> transitions_resources;
    Gtk.StringList transition_list;
    string[] trans_names = {
        "Wind",
        "Wrap",
        "Radial",
        "Kaleidoscope",
    };

    public MainWindow (Gtk.Application app) {
        Object (application: app);
        this.default_height = 600;
        this.default_width = 800;

        this.title = "OpenGL Transition Demo";

        header = new Gtk.HeaderBar ();
        header.show_title_buttons = true;

        label = new Gtk.Label ("Duration :");

        duration_adjustment = new Gtk.Adjustment (0.2, 0.1, 10, 0.1, 0.5, 1);
        duration_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, duration_adjustment);

        duration_scale.set_size_request (100, -1);

        header.pack_end (duration_scale);
        header.pack_end (label);

        transitions_resources = new GLib.HashTable<uint, string>(null, null);
        transitions_resources.insert (0, "/github/aeldemery/gtk4_opengl_transition/transition-wind.glsl");
        transitions_resources.insert (1, "/github/aeldemery/gtk4_opengl_transition/transition-directionalwrap.glsl");
        transitions_resources.insert (2, "/github/aeldemery/gtk4_opengl_transition/transition-radial.glsl");
        transitions_resources.insert (3, "/github/aeldemery/gtk4_opengl_transition/transition-kaleidoscope.glsl");

        transition_list = new Gtk.StringList (trans_names);

        transitions = new Gtk.DropDown (transition_list, null);
        transitions.notify["selected"].connect (transitions_changed_cb);

        label = new Gtk.Label ("Shaders :");
        header.pack_start (label);
        header.pack_start (transitions);

        this.set_titlebar (header);

        box = new Gtk.Box (Gtk.Orientation.VERTICAL, 40);
        box.halign = box.valign = Gtk.Align.CENTER;
        box.margin_top = box.margin_bottom = box.margin_start = box.margin_end = 60;
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 40);
        hbox.halign = hbox.valign = Gtk.Align.CENTER;

        stack = new TransitionStack ();
        duration_scale.adjustment.bind_property ("value", stack, "duration");

        previous = new Gtk.Button.from_icon_name ("go-previous-symbolic");
        previous.clicked.connect (() => {
            stack.transit_backward ();
        });

        next = new Gtk.Button.from_icon_name ("go-next-symbolic");
        next.clicked.connect (() => {
            stack.transit_forward ();
        });

        bin = new RippleBin (previous);
        hbox.append (bin);
        bin = new RippleBin (next);
        hbox.append (bin);

        bin = new RippleBin (stack);
        box.append (bin);
        box.append (hbox);

        background_shader = new Gsk.GLShader.from_resource ("/github/aeldemery/gtk4_opengl_transition/background.glsl");
        background_paintable = new ShaderPaintable (background_shader);
        background_pic = new Gtk.Picture.for_paintable (background_paintable);
        background_pic.vexpand = background_pic.hexpand = true;
        background_pic.add_tick_callback (background_cb);
        background_grid = new Gtk.Grid ();
        background_grid.attach (background_pic, 0, 0);

        background_grid.attach (box, 0, 0);

        // outer_grid.attach (picture, 0, 0);
        this.set_child (background_grid);
    }

    void transitions_changed_cb (GLib.Object obj_drop, GLib.ParamSpec pspec) {
        var drop = (Gtk.DropDown)obj_drop;
        var resource = transitions_resources.get (drop.selected);
        stack.change_transition_shader (resource);
    }

    static bool background_cb (Gtk.Widget widget, Gdk.FrameClock clock) {
        var pic = (Gtk.Picture)widget;
        var paintable = (ShaderPaintable) pic.paintable;
        paintable.update_time (0, clock.get_frame_time ());
        return Source.CONTINUE;
    }
}