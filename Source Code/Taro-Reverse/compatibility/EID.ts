import { ModCallbackCustom } from "isaacscript-common"
import type { ModUpgradedWithFeatures } from "isaacscript-common/dist/types/private/ModUpgradedWithFeatures"

let didInit = false

export function initEID(mod: ModUpgradedWithFeatures<never[]>) {
	mod.AddCallbackCustom(
		ModCallbackCustom.POST_GAME_STARTED_REORDERED,
		() => {
			if (didInit) return
			didInit = true

			if (!EID) return

			const taroReverseID = Isaac.GetItemIdByName("Taro Reverse")

			EID.addCollectible(
				taroReverseID,
				"Turns over the tarot card in the character's hand",
				undefined,
				"en_us",
			)

			// Spanish / Español
			EID.addCollectible(
				taroReverseID,
				"Voltea la carta tarot en la mano del jugador",
				undefined,
				"spa",
			)

			EID.addCondition(
				"5.300.1",
				taroReverseID,
				"{{Card56}} Suelta todos los corazones y recolectables en el piso, dejando a Isaac a medio corazón",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.2",
				taroReverseID,
				"{{Card57}} Brinda una aura azul repelente por un minuto",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.3",
				taroReverseID,
				"{{Card58}} La pierna de mom comienza a caer repetidamente por un minuto",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.4",
				taroReverseID,
				"{{Card59}} Brinda 2 contenedores de corazón temporales y +1.35 lagrimas por un minuto",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.5",
				taroReverseID,
				"{{Card60}} Teletransporta a Isaac a una Habitación del Jefe extra. El jefe dará un item adicional, pero la habitación no tendrá trampilla",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.6",
				taroReverseID,
				"{{Card61}} Aparece 2 corazones de hueso",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.7",
				taroReverseID,
				"{{Card62}} Aparece un item aleatorio de la pool de objetos de la sala actual. Convierte un contenedor de corazón o dos corazones de alma en un corazón roto",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.8",
				taroReverseID,
				"{{Card63}} Isaac se vuelve una estatua invencible con una cadencia de disparo extremadamente alta por 10 segundos",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.9",
				taroReverseID,
				"{{Card64}} Aparece de 2 a 4 cofres dorados",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.10",
				taroReverseID,
				'{{Card65}} "Vende" los items y recolectables por su valor estándar en la tienda, haciendo aparecer un valor equivalente de monedas',
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.11",
				taroReverseID,
				"{{Card66}} Activa el efecto de un dado aleatorio, desde d4 hasta d100",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.12",
				taroReverseID,
				"{{Card67}} Todos los enemigos en la habitación son debilitados, haciéndose más lentos y reciben el doble de daño",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.13",
				taroReverseID,
				"{{Card68}} Isaac cambia visualmente a Keeper por 30 segundos, obtiene triple disparo, no hay daño adicional y -0.1 de velocidad",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.14",
				taroReverseID,
				"{{Card69}} Activa el efecto de Book of the Dead",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.15",
				taroReverseID,
				"{{Card70}} Fuerza a Isaac a comer 5 píldoras aleatorias en una sucesión rápida.",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.16",
				taroReverseID,
				"{{Card71}} Invoca un Seraphim como familiar, activa el efecto de The Bible y da vuelo por 30 segundos",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.17",
				taroReverseID,
				"{{Card72}} Aparece 6 grupos de rocas aleatorias y otros obstáculos",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.18",
				taroReverseID,
				"{{Card73}} Remueve el item pasivo de Isaac más antiguo, incluyendo objetos iniciales, y aparece 2 items aleatorios de la pool de objetos de la habitación actual",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.19",
				taroReverseID,
				"{{Card74}} Teletransporta el jugador a la Habitación Super Secreta",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.20",
				taroReverseID,
				"{{Card75}} Isaac obtiene el efecto de Spirit of the Night y +1.5 de daño durante todo el piso. Convierte los contenedores de corazones de Isaac en corazones de hueso",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.21",
				taroReverseID,
				"{{Card76}} Aparece una maquina de restock",
				undefined,
				"spa",
			)

			EID.addCondition(
				"5.300.56",
				taroReverseID,
				"{{Card1}} Teletransporta al jugador a la habitación del comienzo actual",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.57",
				taroReverseID,
				"{{Card2}} Las lagrimas de Isaac se tornan moradas y pueden ir directo hacia los enemigos hasta que salgas de la habitación",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.58",
				taroReverseID,
				"{{Card3}} Invoca el pié de Mamá, el cual aplastará a un enemigo cualquiera (Va hacia el jugador si no hay enemigos)",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.59",
				taroReverseID,
				"{{Card4}} Convierte al jugador en un demonio, incrementando su ataque en 2 y velocidad en 1 hasta salir de la habitación",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.60",
				taroReverseID,
				"{{Card5}} Teletransporta al jugador a la Habitación del Jefe",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.61",
				taroReverseID,
				"{{Card6}} Aparecen 2 corazones de alma",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.62",
				taroReverseID,
				"{{Card7}} Aparecen 2 corazones enteros",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.63",
				taroReverseID,
				"{{Card8}} Te da invencibilidad temporal, y puedes atacar enemigos al contacto.",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.64",
				taroReverseID,
				"{{Card9}} Aparece 1 bomba, 1 llave, 1 moneda y 1 corazón",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.65",
				taroReverseID,
				"{{Card10}} Teletransporta al jugador a la Tienda",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.66",
				taroReverseID,
				"{{Card11}} Aparece una Maquina tragaperras",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.67",
				taroReverseID,
				"{{Card12}} Hace al jugador mas grande, incrementa la vida máxima y el ataque hasta que se sale de la habitación",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.68",
				taroReverseID,
				"{{Card13}} Remueve el cuerpo del jugador permitiéndote volar sobre obstáculos, púas y fosas hasta salir de la habitación",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.69",
				taroReverseID,
				"{{Card14}} Daña a todos los enemigos de la habitación significativamente",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.70",
				taroReverseID,
				"{{Card15}} Aparece una Maquina de donación de sangre",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.71",
				taroReverseID,
				"{{Card16}} Incrementa tu ataque en 2 hasta que salgas de la habitación.",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.72",
				taroReverseID,
				"{{Card17}} Aparecen seis bombas Trolls en la habitación",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.73",
				taroReverseID,
				"{{Card18}} Teletransporta al jugador a la Habitación del Tesoro",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.74",
				taroReverseID,
				"{{Card19}} Teletransporta al jugador a la Habitación Secreta",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.75",
				taroReverseID,
				"{{Card20}} Restaura la salud del jugador, daña a todos los enemigos y revela el mapa completo con todas las habitaciones especiales",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.76",
				taroReverseID,
				"{{Card21}} Hace aparecer un Mendigo",
				undefined,
				"spa",
			)
			EID.addCondition(
				"5.300.77",
				taroReverseID,
				"{{Card22}} Revela todas las habitaciónes del piso, a excepción de la Habitación Super Secreta",
				undefined,
				"spa",
			)
		},
		undefined,
	)
}
