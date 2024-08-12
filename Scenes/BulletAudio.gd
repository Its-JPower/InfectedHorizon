extends AudioStreamPlayer2D

@onready var player = $Player

func _ready():
	connect('finished', Callable(self, 'queue_free')) # or you can connect this in the Inspector and delete this line
	get_parent().connect('tree_exiting', Callable(self, '_reparent'))

func _reparent():
	get_parent().remove_child(self)
	get_parent().get_parent().add_child(self)
