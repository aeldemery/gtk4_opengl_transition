public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    TransitionStack stack;
    RippleBin bin;

    Gtk.Box box;
    Gtk.Box hbox;

    Gtk.Button next;
    Gtk.Button previous;
    Gtk.CenterBox center;
    Gtk.Label label;
    
    Gtk.HeaderBar header;
    Gtk.Scale duration_scale;
    Gtk.Adjustment duration;
    Gtk.DropDown transitions;

    GLib.HashTable<string, string> transitions_resources;
    Gtk.StringList transition_list;
    string[] trans_names = {
        "Wind",
        "Directional Wrap",
    };

    public MainWindow (Gtk.Application app) {
        Object (application: app);
        this.default_height = 600;
        this.default_width = 800;

        this.title = "OpenGL Transition Demo";

        header = new Gtk.HeaderBar ();
        header.show_title_buttons = true;

        duration = new Gtk.Adjustment (0.2, 0, 100, 0.1, 0.5, 1);
        duration_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, duration);
        duration_scale.set_size_request (100, -1);

        header.pack_end (duration_scale);

        transitions_resources = new GLib.HashTable<string,string> (str_hash, str_equal);
        transitions_resources.insert ("Transition Wind", "/github/aeldemery/gtk4_opengl_transition/transition-wind.glsl");

        transition_list = new Gtk.StringList (trans_names);

        transitions = new Gtk.DropDown (transition_list, null);

        header.pack_start (transitions);

        this.set_titlebar (header);

        box = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);

        center = new Gtk.CenterBox ();
        label = new Gtk.Label ("");

        center.set_center_widget (label);

        box.append (center);

        //transitions.bind_property ("selected-item", label, "label");

        stack = new TransitionStack ();
        duration.bind_property ("value", stack, "duration");

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

        // outer_grid.attach (picture, 0, 0);
        this.set_child (box);
    }
}