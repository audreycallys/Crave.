import { Router } from "express";
import EntriesController from "../../controllers/entries/entries.controller";
import { uploadSingleImage } from "../../middleware/upload.middleware";
import { authMiddleware } from "../../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware);

/**
 * @swagger
 * /api/entries:
 *   post:
 *     summary: Create a new culinary entry
 *     tags: [Entries]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - menuName
 *               - category
 *               - price
 *               - dateTried
 *               - rating
 *               - photo
 *             properties:
 *               menuName:
 *                 type: string
 *                 example: Matcha Latte
 *               placeName:
 *                 type: string
 *                 example: Kopi Kenangan
 *               category:
 *                 type: string
 *                 enum: [Food, Drink]
 *               price:
 *                 type: number
 *                 example: 25000
 *               dateTried:
 *                 type: string
 *                 format: date
 *                 example: "2026-11-01"
 *               rating:
 *                 type: integer
 *                 minimum: 1
 *                 maximum: 5
 *                 example: 5
 *               notes:
 *                 type: string
 *                 example: Rasanya enak dan creamy
 *               isPublic:
 *                 type: string
 *                 enum: ["true", "false"]
 *                 example: "false"
 *               photo:
 *                 type: string
 *                 format: binary
 *     responses:
 *       201:
 *         description: Entry created successfully
 *       400:
 *         description: Validation failed or photo missing
 *       401:
 *         description: Unauthorized
 */
router.post("/", uploadSingleImage, EntriesController.createEntry);

/**
 * @swagger
 * /api/entries:
 *   get:
 *     summary: Get all public culinary entries
 *     tags: [Entries]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Public entries retrieved successfully
 *       401:
 *         description: Unauthorized
 */
router.get("/", EntriesController.getAllEntries);

/**
 * @swagger
 * /api/entries/my:
 *   get:
 *     summary: Get all entries belonging to the logged-in user
 *     tags: [Entries]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: My entries retrieved successfully
 *       401:
 *         description: Unauthorized
 */
router.get("/my", EntriesController.getMyEntries);

/**
 * @swagger
 * /api/entries/{id}:
 *   get:
 *     summary: Get a public entry or an entry belonging to the logged-in user
 *     tags: [Entries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Entry ID
 *     responses:
 *       200:
 *         description: Entry retrieved successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Entry not found
 */
router.get("/:id", EntriesController.getEntryById);

/**
 * @swagger
 * /api/entries/{id}:
 *   put:
 *     summary: Update an entry belonging to the logged-in user
 *     tags: [Entries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Entry ID
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               menuName:
 *                 type: string
 *                 example: Iced Matcha Latte
 *               placeName:
 *                 type: string
 *                 example: Kopi Kenangan
 *               category:
 *                 type: string
 *                 enum: [Food, Drink]
 *               price:
 *                 type: number
 *                 example: 30000
 *               dateTried:
 *                 type: string
 *                 format: date
 *                 example: "2026-11-01"
 *               rating:
 *                 type: integer
 *                 minimum: 1
 *                 maximum: 5
 *                 example: 4
 *               notes:
 *                 type: string
 *                 example: Rasanya cukup enak
 *               isPublic:
 *                 type: string
 *                 enum: ["true", "false"]
 *                 example: "true"
 *               photo:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Entry updated successfully
 *       400:
 *         description: Validation failed
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Entry not found
 */
router.put("/:id", uploadSingleImage, EntriesController.updateEntry);

/**
 * @swagger
 * /api/entries/{id}:
 *   delete:
 *     summary: Delete an entry belonging to the logged-in user
 *     tags: [Entries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Entry ID
 *     responses:
 *       200:
 *         description: Entry deleted successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Entry not found
 */
router.delete("/:id", EntriesController.deleteEntry);

export default router;
