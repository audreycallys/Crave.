import { Router } from "express";

import UsersController from "../../controllers/users/users.controller";
import { authMiddleware } from "../../middleware/auth.middleware";
import { uploadSingleImage } from "../../middleware/upload.middleware";

const router = Router();

router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: Users
 *   description: User profile management
 */

/**
 * @swagger
 * /api/users/profile:
 *   get:
 *     summary: Get current user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile retrieved successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */
router.get("/profile", UsersController.getMyProfile);

/**
 * @swagger
 * /api/users/profile:
 *   put:
 *     summary: Update current user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: Audrey
 *               bio:
 *                 type: string
 *                 example: Exploring new food and drink experiences.
 *               photo:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Profile updated successfully
 *       400:
 *         description: Validation failed
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: User not found
 */
router.put("/profile", uploadSingleImage, UsersController.updateMyProfile);

export default router;
