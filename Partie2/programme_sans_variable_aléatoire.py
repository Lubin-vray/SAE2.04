import pygame          # On importe la bibliothèque qui sert à dessiner.
import random          # On importe la bibliothèque qui sert à faire du hasard.
import sys             # On importe sys pour pouvoir quitter proprement le programme.

# 1. PARAMÈTRES GÉNÉRAUX
LARGEUR, HAUTEUR = 4000, 4800   # Taille de l'image finale en pixels.
COULEUR_FOND = (234, 230, 226)  # Couleur de fond de l'image.
COULEUR_TRAIT = (65, 64, 58)    # Couleur des lignes dessinées.

EPAISSEUR_TRAIT = 4             # Épaisseur des lignes.

# Paramètres de la grille
NB_COLONNES = 14                # Nombre de colonnes dans la grille.
NB_LIGNES = 19                  # Nombre de lignes dans la grille.
TAILLE_CASE = 250               # Largeur et hauteur d'une case.
MARGE = 20                      # Espace laissé entre le dessin et le bord de la case.
NB_SEGMENTS = 13               # Nombre de segments pour chaque figure.


# 2. FONCTION POUR DESSINER UNE SEULE FIGURE
def dessiner_une_figure(surface, x_case, y_case):
    # x_case et y_case sont la position du coin haut-gauche de la case.

    x_min = x_case + MARGE
    # Bord gauche autorisé pour dessiner dans la case.

    x_max = x_case + TAILLE_CASE - MARGE
    # Bord droit autorisé pour dessiner dans la case.

    y_min = y_case + MARGE
    # Bord haut autorisé pour dessiner dans la case.

    y_max = y_case + TAILLE_CASE - MARGE
    # Bord bas autorisé pour dessiner dans la case.

    x = random.uniform(x_min, x_max)
    # On choisit un premier x au hasard dans la case.

    y = random.uniform(y_min, y_max)
    # On choisit un premier y au hasard dans la case.

    x_depart = x
    # On garde le x de départ pour fermer la figure à la fin.

    y_depart = y
    # On garde le y de départ pour fermer la figure à la fin.

    points = [(x, y)]
    # On crée une liste avec le premier point.

    for i in range(NB_SEGMENTS):
        tirage = random.randint(1, 100)

        if tirage <= 10:
            choix = "diagonale"    
        else:
            choix = "horizontalvertical"  
        # On choisit au hasard si le prochain segment sera horizontal ou vertical.
        if choix == 'horizontalvertical':
        # Cette boucle va ajouter des segments à la figure.
            x = random.uniform(x_min, x_max)
            # On change seulement la coordonnée x.

            points.append((x, y))
            # On ajoute un nouveau point.
            # Comme seul x change, on trace une ligne horizontale.

            y = random.uniform(y_min, y_max)
            # On change seulement la coordonnée y.

            points.append((x, y))
            # On ajoute encore un point.
            # Comme seul y change, on trace une ligne verticale.
        if choix == 'diagonale':
            x = random.uniform(x_min, x_max)
            y = random.uniform(y_min, y_max)
            # On change à la fois x et y.
            points.append((x, y))

    points.append((x_depart, y))
    # On revient d'abord sur la même ligne horizontale que la fin.

    points.append((x_depart, y_depart))
    # Puis on revient exactement au point de départ.
    # Cela ferme la figure sans diagonale.

    pygame.draw.lines(surface, COULEUR_TRAIT, False, points, EPAISSEUR_TRAIT)
    # On dessine toutes les lignes en reliant les points dans l'ordre.

# 3. PROGRAMME PRINCIPAL
# ----------------------
pygame.init()
# On démarre Pygame.

surface = pygame.Surface((LARGEUR, HAUTEUR))
# On crée une grande image vide.

surface.fill(COULEUR_FOND)
# On remplit toute l'image avec la couleur de fond.

largeur_grille = NB_COLONNES * TAILLE_CASE
# Largeur totale de la grille.

hauteur_grille = NB_LIGNES * TAILLE_CASE
# Hauteur totale de la grille.

decalage_x = (LARGEUR - largeur_grille) / 2
# Décalage horizontal pour centrer la grille dans l'image.

decalage_y = (HAUTEUR - hauteur_grille) / 2
# Décalage vertical pour centrer la grille dans l'image.

for col in range(NB_COLONNES):
    # Boucle sur les colonnes.

    for ligne in range(NB_LIGNES):
        # Boucle sur les lignes.

        x_case = decalage_x + col * TAILLE_CASE
        # Position x de la case actuelle.

        y_case = decalage_y + ligne * TAILLE_CASE
        # Position y de la case actuelle.

        dessiner_une_figure(surface, x_case, y_case)
        # On dessine une figure dans cette case.
        
# Sauvegarde finale
pygame.image.save(surface, "oeuvre_4k_etudiant.png")
print("Sauvegardée: oeuvre_4k_etudiant.png")

pygame.quit()
sys.exit()