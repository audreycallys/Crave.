import { Router } from "express";

import CommentsController from "../../controllers/comments/comments.controller";
import { authMiddleware } from "../../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: Comments
 *   description: Comment management
 */

/**
 * @swagger
 * /api/comments/entries/{id}:
 *   get:
 *     summary: Get comments from an entry
 *     tags: [Comments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Comments retrieved successfully
 *       404:
 *         description: Entry not found
 */
router.get("/entries/:id", CommentsController.getComments);

/**
 * @swagger
 * /api/comments/entries/{id}:
 *   post:
 *     summary: Create a comment on an entry
 *     tags: [Comments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - content
 *             properties:
 *               content:
 *                 type: string
 *                 example: This looks delicious!
 *     responses:
 *       201:
 *         description: Comment created successfully
 *       400:
 *         description: Validation failed
 *       404:
 *         description: Entry not found
 */
router.post("/entries/:id", CommentsController.createComment);

/**
 * @swagger
 * /api/comments/{id}:
 *   put:
 *     summary: Update your own comment
 *     tags: [Comments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - content
 *             properties:
 *               content:
 *                 type: string
 *                 example: I really enjoyed this!
 *     responses:
 *       200:
 *         description: Comment updated successfully
 *       403:
 *         description: Not allowed to edit this comment
 *       404:
 *         description: Comment or entry not found
 */
router.put("/:id", CommentsController.updateComment);

/**
 * @swagger
 * /api/comments/{id}:
 *   delete:
 *     summary: Delete a comment
 *     tags: [Comments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Comment deleted successfully
 *       403:
 *         description: Not allowed to delete this comment
 *       404:
 *         description: Comment not found
 */
router.delete("/:id", CommentsController.deleteComment);

export default router;
