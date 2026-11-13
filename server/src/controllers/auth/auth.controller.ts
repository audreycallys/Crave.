import { Request, Response } from "express";
import { db } from "../../config/db";
import { eq } from "drizzle-orm";
import { usersTable } from "../../config/schema";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import {
  loginSchema,
  registerSchema,
} from "../../validations/auth/auth.validation";
import { AuthRequest } from "../../middleware/auth.middleware";
import { changePasswordSchema } from "../../validations/auth/auth.validation";

export class AuthController {
  register = async (req: Request, res: Response) => {
    try {
      const validatedData = registerSchema.parse(req.body);
      const { name, email, password } = validatedData;

      const existingEmail = await db.query.usersTable.findFirst({
        where: eq(usersTable.email, email),
      });

      if (existingEmail) {
        return res.status(409).json({
          success: false,
          message: "Email already exists",
        });
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      const [insertedUser] = await db
        .insert(usersTable)
        .values({
          name: name,
          email: email,
          password: hashedPassword,
        })
        .$returningId();

      const newUser = await db.query.usersTable.findFirst({
        where: eq(usersTable.id, insertedUser.id),
      });

      return res.status(201).json({
        success: true,
        message: "Register successful",
        data: {
          user: {
            id: newUser?.id,
            name: newUser?.name,
            email: newUser?.email,
            role: newUser?.role,
          },
        },
      });
    } catch (error: any) {
      console.error(error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };

  login = async (req: Request, res: Response) => {
    try {
      const validatedData = loginSchema.parse(req.body);
      const { email, password } = validatedData;

      const user = await db.query.usersTable.findFirst({
        where: eq(usersTable.email, email),
      });

      if (!user) {
        return res.status(401).json({
          success: false,
          message: "Email or password incorrect",
        });
      }

      const isPasswordValid = await bcrypt.compare(password, user.password);

      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: "Email or password incorrect",
        });
      }

      const token = jwt.sign(
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        },
        process.env.JWT_SECRET as string,
        {
          expiresIn: "7d",
        },
      );

      return res.status(200).json({
        success: true,
        message: "Login successful",
        data: {
          token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
          },
        },
      });
    } catch (error: any) {
      console.error(error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };

  changePassword = async (req: AuthRequest, res: Response) => {
    try {
      const validation = changePasswordSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: validation.error.flatten().fieldErrors,
        });
      }

      const { currentPassword, newPassword } = validation.data;
      const userId = req.user!.id;

      const user = await db.query.usersTable.findFirst({
        where: eq(usersTable.id, userId),
      });

      if (!user) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }

      const isPasswordValid = await bcrypt.compare(
        currentPassword,
        user.password,
      );

      if (!isPasswordValid) {
        return res.status(400).json({
          success: false,
          message: "Current password is incorrect",
        });
      }

      const isSamePassword = await bcrypt.compare(newPassword, user.password);

      if (isSamePassword) {
        return res.status(400).json({
          success: false,
          message: "New password must be different from current password",
        });
      }

      const hashedPassword = await bcrypt.hash(newPassword, 10);

      await db
        .update(usersTable)
        .set({ password: hashedPassword })
        .where(eq(usersTable.id, userId));

      return res.status(200).json({
        success: true,
        message: "Password changed successfully",
      });
    } catch (error: any) {
      console.error("Change password error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to change password",
      });
    }
  };
}

export default new AuthController();
