import { Router } from "express";

import UsersController from "../../controllers/users/users.controller";
import { authMiddleware } from "../../middleware/auth.middleware";
import { uploadSingleImage } from "../../middleware/upload.middleware";

const router = Router();

router.use(authMiddleware);

router.get("/profile", UsersController.getMyProfile);

router.put("/profile", uploadSingleImage, UsersController.updateMyProfile);

export default router;
