extends TextureProgressBar

var maxvalor:int

func _ready():
	maxvalor=2
	
func Disminuirbala(balas):
	value-=balas
	if value ==0:
		get_tree().get_nodes_in_group("player")[0].recargarbalas()
		value+=1
		value+=1
