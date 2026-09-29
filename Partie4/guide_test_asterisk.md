# 📋 Guide de test — Configuration Asterisk Atelier

> **Serveur :** 13.36.210.156 | **Date :** 09/06/2026 | **Solution :** Asterisk sur Debian AWS

---

## Test 1 — Appel interne 200 → 201

**Action :** Depuis le softphone 200, compose `201`

**Attendu :** Le poste 201 sonne → décrocher → conversation possible dans les deux sens

📸 *Capture à insérer : softphone 201 qui sonne*

---

## Test 2 — IVR principal

```bash
asterisk -rx "channel originate PJSIP/200 extension s@ivr"
```

Cette commande simule un appel entrant vers l'IVR depuis le poste 200.  
Le softphone 200 sonne → décroche → tu entends le message d'accueil → appuie sur `0/1/2/3` pour être routé vers l'artiste correspondant.

📸 *Capture à insérer : logs IVR dans la console Asterisk*

---

## Test 3 — Annonce hors horaires

```bash
asterisk -rx "channel originate PJSIP/200 extension s@announce_closed"
```

Simule un appel en dehors des horaires d'ouverture.  
Le softphone 200 sonne → décroche → tu entends **"l'atelier est fermé"** → raccroche automatiquement.

📸 *Capture à insérer : logs announce_closed*

---

## Test 4 — Annonce vacances

```bash
asterisk -rx "database put vacation mode on"
asterisk -rx "channel originate PJSIP/200 extension s@announce_vacation"
asterisk -rx "database del vacation mode"
```

- `database put` active le mode vacances dans la base interne d'Asterisk
- `channel originate` simule l'appel → tu entends **"l'atelier est en vacances"**
- `database del` désactive le mode vacances après le test

📸 *Capture à insérer : logs announce_vacation*

---

## Test 5 — Vérification horaires (check_time)

```bash
asterisk -rx "channel originate PJSIP/200 extension s@check_time"
```

Asterisk vérifie l'heure système et les vacances puis route automatiquement :

| Condition | Résultat |
|---|---|
| Dans les horaires (8h-18h lun-ven) | → IVR |
| Hors horaires | → Annonce fermé |
| Mode vacances ON | → Annonce vacances |

> Pour simuler une heure précise :
```bash
date -s "2026-06-09 23:00:00"
asterisk -rx "channel originate PJSIP/200 extension s@check_time"
timedatectl set-ntp true
```

📸 *Capture à insérer : logs check_time avec GotoIfTime*

---

## Test 6 — Mode absent

**Étape 1 :** Depuis le softphone 200, compose `*72`

→ Tu entends un **bip** = mode absent activé sur le poste 200

**Étape 2 :** Depuis le softphone 201, appelle le `200`

→ **Attendu :** la messagerie vocale de 200 répond directement

**Étape 3 :** Depuis le softphone 200, compose `*73`

→ Tu entends un **bip** = mode absent désactivé

📸 *Capture à insérer : appel vers 200 redirigé vers messagerie*

---

## Test 7 — Messagerie vocale

**Action :** Depuis n'importe quel softphone, compose `*97`

→ Tu entends **"Entrez votre numéro de boîte vocale"** → saisir `200` → PIN : `1234` → accès aux messages

📸 *Capture à insérer : softphone avec accès messagerie*

---

## Test 8 — SDA Léon (0477777777)

```bash
asterisk -rx "channel originate PJSIP/200 extension 0477777777@from-provider"
```

Simule un appel entrant sur le numéro direct de Léon.  
Le softphone 200 **sonne directement** sans passer par l'IVR.

📸 *Capture à insérer : poste 200 qui sonne sur appel SDA*

---

## Test 9 — SDA Mickael (0488888888)

```bash
asterisk -rx "channel originate PJSIP/202 extension 0488888888@from-provider"
```

Simule un appel entrant sur le numéro direct de Mickael.  
Le softphone 202 **sonne directement** sans passer par l'IVR.

📸 *Capture à insérer : poste 202 qui sonne sur appel SDA*

---

## Récapitulatif des tests

| # | Test | Commande / Action | Attendu | ✅/❌ |
|---|---|---|---|---|
| 1 | Appel interne | Composer `201` depuis 200 | 201 sonne | |
| 2 | IVR | `originate s@ivr` | Message d'accueil + menu | |
| 3 | Annonce fermé | `originate s@announce_closed` | Message fermé | |
| 4 | Annonce vacances | `database put` + `originate` | Message vacances | |
| 5 | check_time | `originate s@check_time` | Routage selon heure | |
| 6 | Mode absent | `*72` → appel → `*73` | Renvoi messagerie | |
| 7 | Messagerie | `*97` + PIN 1234 | Accès boîte vocale | |
| 8 | SDA Léon | `originate 0477777777@from-provider` | 200 sonne direct | |
| 9 | SDA Mickael | `originate 0488888888@from-provider` | 202 sonne direct | |

---

## Commandes de diagnostic utiles

```bash
# Vérifier le service
systemctl status asterisk

# Voir les postes connectés
asterisk -rx "pjsip show endpoints"
asterisk -rx "pjsip show contacts"

# Debug live (voir les logs en temps réel)
asterisk -rvvvv

# Recharger le dialplan
asterisk -rx "dialplan reload"
```

---

*Projet SAÉ2.04 Partie 4 — Atelier d'artistes — Asterisk sur Debian AWS — 09/06/2026*
