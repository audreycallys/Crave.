import { Router } from "express";
import EntriesController from "../../controllers/entries/entries.controller";
import { uploadSingleImage } from "../../middleware/upload.middleware";

const router = Router();

/**
 * @swagger
 * /api/entries:
 *   post:
 *     summary: Create a new culinary entry
 *     tags: [Entries]
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - menuName
 *               - category
 *               - price
 *               - dateTried
 *               - rating
 *               - photo
 *             properties:
 *               userId:
 *                 type: integer
 *                 example: 1
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
 *               photo:
 *                 type: string
 *                 format: binary
 *     responses:
 *       201:
 *         description: Entry created successfully
 *       400:
 *         description: Validation failed or photo missing
 */
router.post("/", uploadSingleImage, EntriesController.createEntry);

/**
 * @swagger
 * /api/entries:
 *   get:
 *     summary: Get all culinary entries
 *     tags: [Entries]
 *     responses:
 *       200:
 *         description: Entries retrieved successfully
 */
router.get("/", EntriesController.getAllEntries);

/**
 * @swagger
 * /api/entries/{id}:
 *   get:
 *     summary: Get culinary entry by ID
 *     tags: [Entries]
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
 *       404:
 *         description: Entry not found
 */
router.get("/:id", EntriesController.getEntryById);

/**
 * @swagger
 * /api/entries/{id}:
 *   put:
 *     summary: Update a culinary entry
 *     tags: [Entries]
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
 *               photo:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Entry updated successfully
 *       400:
 *         description: Validation failed
 *       404:
 *         description: Entry not found
 */
router.put("/:id", uploadSingleImage, EntriesController.updateEntry);

export default router;
