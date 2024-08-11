extends TextureProgressBar

var maxvalor:int

func _ready():
	maxvalor=2
	
func Disminuirbala(balas):
	value-=balas
	if value ==0:
		pass
		#get_tree().get_nodes_in_group("player")[0].dead()
