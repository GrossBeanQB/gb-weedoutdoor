Hi.

I am presenting you a QBCore-friendly script that works with default resources.

🌱 With this script, you can plant weed **anywhere** in the world.

👨‍🌾 You can:
- Harvest plants
- Check plant status via a clean NUI interface
- Add water and fertilizer
- Watch growth progress

🌿 When you harvest a plant, a **weed branch** will be visually attached to your back (only if you have the leaf item in your inventory).  
If the leaf item is missing, the back prop won't appear.

📦 There are **two different weed processing tables** on the map where you can convert weed into baggies.

---

! IMPORTANT !

Go to your SQL database and drop this code inside so it can create the table!

CREATE TABLE IF NOT EXISTS `weed_plants` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `coords` JSON NOT NULL,
    `model` VARCHAR(50) NOT NULL,
    `label` VARCHAR(50) NOT NULL,
    `stage` INT NOT NULL DEFAULT 1,
    `health` INT NOT NULL DEFAULT 100,
    `food` INT NOT NULL DEFAULT 100,
    `water` INT NOT NULL DEFAULT 100,
    `progress` INT NOT NULL DEFAULT 0,
    `sort` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id`)
);

---


🔬 TEST THE SEED PLANTING:

Run this command:

(example)

giveitem <id> weed_whitewidow_seed 1

→ Press USE in your inventory  
→ A progress bar appears with a planting animation  
→ The plant starts growing

---


Weed Processing Table Location:

vector3(-36.9, -2689.80, 6.0)

For testing:
Use: /tp vector3(-36.9, -2689.80, 6.0)

---

ADD THESE INTO "qb-core/shared/items.lua":

---
['weed_ak47_bud'] = {
    name = 'weed_ak47_bud', 
    label = 'AK47 Bud', 
    weight = 50, 
    type = 'item', 
    image = 'weed_ak47_bud.png', 
    unique = false, 
    useable = false, 
    description = 'Fresh AK47 cannabis bud, ready for processing or use'
},

['weed_amnesia_bud'] = {
    name = 'weed_amnesia_bud', 
    label = 'Amnesia Bud', 
    weight = 50, 
    type = 'item', 
    image = 'weed_amnesia_bud.png', 
    unique = false, 
    useable = false, 
    description = 'A high-quality bud from an Amnesia cannabis plant'
},

['weed_purple_haze_bud'] = {
    name = 'weed_purple_haze_bud', 
    label = 'Purple Haze Bud', 
    weight = 50, 
    type = 'item', 
    image = 'weed_purple_haze_bud.png', 
    unique = false, 
    useable = false, 
    description = 'A potent bud from a Purple Haze cannabis plant'
},

['weed_og_kush_bud'] = {
    name = 'weed_og_kush_bud', 
    label = 'OG Kush Bud', 
    weight = 50, 
    type = 'item', 
    image = 'weed_og_kush_bud.png', 
    unique = false, 
    useable = false, 
    description = 'Premium OG Kush bud, known for its strong effects'
},

['weed_skunk_bud'] = {
    name = 'weed_skunk_bud', 
    label = 'Skunk Bud', 
    weight = 50, 
    type = 'item', 
    image = 'weed_skunk_bud.png', 
    unique = false, 
    useable = false, 
    description = 'A strong-smelling bud from a Skunk strain cannabis plant'
},

['weed_white_widow_bud'] = {
    name = 'weed_white_widow_bud', 
    label = 'White Widow Bud', 
    weight = 50, 
    type = 'item', 
    image = 'weed_white_widow_bud.png', 
    unique = false, 
    useable = false, 
    description = 'A legendary White Widow bud, prized for its balanced high'
},

    ['weed_ak47_leaf'] = {
        name = 'weed_ak47_leaf', 
        label = 'AK47 Leaf', 
        weight = 50, 
        type = 'item', 
        image = 'weed_ak47_leaf.png', 
        unique = false, 
        useable = false, 
        description = 'Weed leaves from an AK47 plant'
    },

    ['weed_amnesia_leaf'] = {
        name = 'weed_amnesia_leaf', 
        label = 'Amnesia Leaf', 
        weight = 50, 
        type = 'item', 
        image = 'weed_amnesia_leaf.png', 
        unique = false, 
        useable = false, 
        description = 'Weed leaves from an Amnesia plant'
    },

    ['weed_purple_haze_leaf'] = {
        name = 'weed_purple_haze_leaf', 
        label = 'Purple Haze Leaf', 
        weight = 50, 
        type = 'item', 
        image = 'weed_purple_haze_leaf.png', 
        unique = false, 
        useable = false, 
        description = 'Weed leaves from a Purple Haze plant'
    },

    ['weed_og_kush_leaf'] = {
        name = 'weed_og_kush_leaf', 
        label = 'OG Kush Leaf', 
        weight = 50, 
        type = 'item', 
        image = 'weed_og_kush_leaf.png', 
        unique = false, 
        useable = false, 
        description = 'Weed leaves from an OG Kush plant'
    },

    ['weed_white_widow_leaf'] = {
        name = 'weed_white_widow_leaf', 
        label = 'White Widow Leaf', 
        weight = 50, 
        type = 'item', 
        image = 'weed_white_widow_leaf.png', 
        unique = false, 
        useable = false, 
        description = 'Weed leaves from a White Widow plant'
    },

    ['weed_skunk_leaf'] = {
        name = 'weed_skunk_leaf', 
        label = 'Skunk Leaf', 
        weight = 50, 
        type = 'item', 
        image = 'weed_skunk_leaf.png', 
        unique = false, 
        useable = false, 
        description = 'Weed leaves from a Skunk plant'
    },

---

AND THIS : 


weed_whitewidow  = { name = 'weed_whitewidow', label = 'White Widow 2g', weight = 200, type = 'item', image = 'weed_baggy_whitewidow.png', unique = false, useable = true, shouldClose = false, description = 'A weed bag with 2g White Widow' },
weed_skunk       = { name = 'weed_skunk', label = 'Skunk 2g', weight = 200, type = 'item', image = 'weed_baggy_skunk.png', unique = false, useable = true, shouldClose = false, description = 'A weed bag with 2g Skunk' },
weed_purplehaze  = { name = 'weed_purplehaze', label = 'Purple Haze 2g', weight = 200, type = 'item', image = 'weed_baggy_purplehaze.png', unique = false, useable = true, shouldClose = false, description = 'A weed bag with 2g Purple Haze' },
weed_ogkush      = { name = 'weed_ogkush', label = 'OGKush 2g', weight = 200, type = 'item', image = 'weed_baggy_ogkush.png', unique = false, useable = true, shouldClose = false, description = 'A weed bag with 2g OG Kush' },
weed_amnesia     = { name = 'weed_amnesia', label = 'Amnesia 2g', weight = 200, type = 'item', image = 'weed_baggy_amnesia.png', unique = false, useable = true, shouldClose = false, description = 'A weed bag with 2g Amnesia' },
weed_ak47        = { name = 'weed_ak47', label = 'AK47 2g', weight = 200, type = 'item', image = 'weed_baggy_ak47.png', unique = false, useable = true, shouldClose = false, description = 'A weed bag with 2g AK47' },

weed_whitewidow_seed = { name = 'weed_whitewidow_seed', label = 'White Widow Seed', weight = 0, type = 'item', image = 'weed_whitewidow_seed.png', unique = false, useable = true, shouldClose = true, description = 'A weed seed of White Widow' },
weed_skunk_seed      = { name = 'weed_skunk_seed', label = 'Skunk Seed', weight = 0, type = 'item', image = 'weed_skunk_seed.png', unique = false, useable = true, shouldClose = true, description = 'A weed seed of Skunk' },
weed_purplehaze_seed = { name = 'weed_purplehaze_seed', label = 'Purple Haze Seed', weight = 0, type = 'item', image = 'weed_purplehaze_seed.png', unique = false, useable = true, shouldClose = true, description = 'A weed seed of Purple Haze' },
weed_ogkush_seed     = { name = 'weed_ogkush_seed', label = 'OGKush Seed', weight = 0, type = 'item', image = 'weed_ogkush_seed.png', unique = false, useable = true, shouldClose = true, description = 'A weed seed of OG Kush' },
weed_amnesia_seed    = { name = 'weed_amnesia_seed', label = 'Amnesia Seed', weight = 0, type = 'item', image = 'weed_amnesia_seed.png', unique = false, useable = true, shouldClose = true, description = 'A weed seed of Amnesia' },
weed_ak47_seed       = { name = 'weed_ak47_seed', label = 'AK47 Seed', weight = 0, type = 'item', image = 'weed_ak47_seed.png', unique = false, useable = true, shouldClose = true, description = 'A weed seed of AK47' },

empty_weed_bag = { name = 'empty_weed_bag', label = 'Empty Weed Bag', weight = 0, type = 'item', image = 'weed_baggy_empty.png', unique = false, useable = true, shouldClose = true, description = 'A small empty bag' },
weed_nutrition = { name = 'weed_nutrition', label = 'Plant Fertilizer', weight = 2000, type = 'item', image = 'weed_nutrition.png', unique = false, useable = true, shouldClose = true, description = 'Plant nutrition' },

---

COPY AND PASTE THE IMAGES FROM THE IMAGES FOLDER INTO:

qb-inventory/html/images/

(If it asks you to overwrite existing files, press YES)


---

Feel free to expand this code, edit it as you wish — this is absolutely free and open source.

Another gift to the QBCore community for those wanting to learn how to script in Lua.

Good luck and enjoy!

– Grossbean
