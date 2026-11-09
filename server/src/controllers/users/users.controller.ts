import { Response } from "express";
import { eq } from "drizzle-orm";
import { usersTable } from "../../config/schema";
import { AuthRequest } from "../../middleware/auth.middleware";
import {
  uploadToCloudinary,
  deleteFromCloudinary,
} from "../../services/cloudinary.service";
import { updateProfileSchema } from "../../validations/users/users.validation";
import { db } from "../../config/db";

class UsersController {
  // GET MY PROFILE
  static getMyProfile = async (req: AuthRequest, res: Response) => {
    try {
      const userId = req.user?.id;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: "Unauthorized",
        });
      }

      const [user] = await db
        .select({
          id: usersTable.id,
          name: usersTable.name,
          email: usersTable.email,
          bio: usersTable.bio,
          profilePhotoUrl: usersTable.profilePhotoUrl,
          role: usersTable.role,
          createdAt: usersTable.createdAt,
        })
        .from(usersTable)
        .where(eq(usersTable.id, userId));

      if (!user) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }

      return res.status(200).json({
        success: true,
        message: "Profile retrieved successfully",
        data: user,
      });
    } catch (error) {
      console.error("Get profile error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve profile",
      });
    }
  };

  // UPDATE MY PROFILE
  static updateMyProfile = async (req: AuthRequest, res: Response) => {
    try {
      const userId = req.user?.id;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: "Unauthorized",
        });
      }

      const validation = updateProfileSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: validation.error.flatten().fieldErrors,
        });
      }

      const { name, bio } = validation.data;

      if (name === undefined && bio === undefined && !req.file) {
        return res.status(400).json({
          success: false,
          message: "Please provide at least one profile field to update",
        });
      }

      const [existingUser] = await db
        .select()
        .from(usersTable)
        .where(eq(usersTable.id, userId));

      if (!existingUser) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }

      let uploadedPhoto: {
        secure_url: string;
        public_id: string;
      } | null = null;

      if (req.file) {
        uploadedPhoto = await uploadToCloudinary(req.file.buffer);
      }

      const updateData: Partial<typeof usersTable.$inferInsert> = {};

      if (name !== undefined) {
        updateData.name = name;
      }

      if (bio !== undefined) {
        updateData.bio = bio;
      }

      if (uploadedPhoto) {
        updateData.profilePhotoUrl = uploadedPhoto.secure_url;
        updateData.profilePhotoPublicId = uploadedPhoto.public_id;
      }

      try {
        await db
          .update(usersTable)
          .set(updateData)
          .where(eq(usersTable.id, userId));
      } catch (error) {
        if (uploadedPhoto) {
          await deleteFromCloudinary(uploadedPhoto.public_id).catch(
            (cleanupError) => {
              console.error("New profile photo cleanup error:", cleanupError);
            },
          );
        }

        throw error;
      }

      // Delete old profile photo after successful update
      if (uploadedPhoto && existingUser.profilePhotoPublicId) {
        try {
          await deleteFromCloudinary(existingUser.profilePhotoPublicId);
        } catch (error) {
          console.error("Old profile photo deletion error:", error);
        }
      }

      const [updatedUser] = await db
        .select({
          id: usersTable.id,
          name: usersTable.name,
          email: usersTable.email,
          bio: usersTable.bio,
          profilePhotoUrl: usersTable.profilePhotoUrl,
          role: usersTable.role,
          createdAt: usersTable.createdAt,
          updatedAt: usersTable.updatedAt,
        })
        .from(usersTable)
        .where(eq(usersTable.id, userId));

      return res.status(200).json({
        success: true,
        message: "Profile updated successfully",
        data: updatedUser,
      });
    } catch (error) {
      console.error("Update profile error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to update profile",
      });
    }
  };
}

export default UsersController;
