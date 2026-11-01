import { Response } from "express";
import { db } from "../../config/db";
import { foodEntriesTable } from "../../config/schema";
import { AuthRequest } from "../../middleware/auth.middleware";
import { and, eq, desc, or } from "drizzle-orm";
import {
  createEntrySchema,
  updateEntrySchema,
} from "../../validations/entries/entries.validation";
import { uploadToCloudinary } from "../../services/cloudinary.service";

export class EntriesController {
  // Create entry
  createEntry = async (req: AuthRequest, res: Response) => {
    try {
      const validation = createEntrySchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: validation.error.flatten().fieldErrors,
        });
      }

      const {
        menuName,
        placeName,
        category,
        price,
        dateTried,
        rating,
        notes,
        isPublic,
      } = validation.data;

      // Check uploaded photo
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: "Photo is required",
        });
      }

      // Upload photo to Cloudinary
      const uploadResult = await uploadToCloudinary(req.file.buffer);
      const photoUrl = uploadResult.secure_url;

      // Insert entry into database
      const [insertedEntry] = await db
        .insert(foodEntriesTable)
        .values({
          userId: req.user!.id,
          menuName,
          placeName: placeName || null,
          category,
          price: price.toFixed(2),
          dateTried,
          rating,
          photoUrl,
          isPublic: isPublic ?? false,
          notes: notes || null,
        })
        .$returningId();

      // Get created entry
      const newEntry = await db.query.foodEntriesTable.findFirst({
        where: eq(foodEntriesTable.id, insertedEntry.id),
      });

      return res.status(201).json({
        success: true,
        message: "Entry created successfully",
        data: {
          entry: newEntry,
        },
      });
    } catch (error: any) {
      console.error("Create entry error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };

  // Get all public entries
  getAllEntries = async (req: AuthRequest, res: Response) => {
    try {
      const entries = await db
        .select()
        .from(foodEntriesTable)
        .where(eq(foodEntriesTable.isPublic, true))
        .orderBy(desc(foodEntriesTable.createdAt));

      return res.status(200).json({
        success: true,
        message: "Public entries retrieved successfully",
        data: {
          entries,
        },
      });
    } catch (error: any) {
      console.error("Get entries error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };

  // Get my entries
  getMyEntries = async (req: AuthRequest, res: Response) => {
    try {
      const entries = await db
        .select()
        .from(foodEntriesTable)
        .where(eq(foodEntriesTable.userId, req.user!.id))
        .orderBy(desc(foodEntriesTable.createdAt));

      return res.status(200).json({
        success: true,
        message: "My entries retrieved successfully",
        data: {
          entries,
        },
      });
    } catch (error: any) {
      console.error("Get my entries error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };

  // Get entry by ID
  getEntryById = async (req: AuthRequest, res: Response) => {
    try {
      const entryId = Number(req.params.id);

      if (!Number.isInteger(entryId) || entryId <= 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid entry ID",
        });
      }

      const entry = await db.query.foodEntriesTable.findFirst({
        where: and(
          eq(foodEntriesTable.id, entryId),
          or(
            eq(foodEntriesTable.isPublic, true),
            eq(foodEntriesTable.userId, req.user!.id),
          ),
        ),
      });

      if (!entry) {
        return res.status(404).json({
          success: false,
          message: "Entry not found",
        });
      }

      return res.status(200).json({
        success: true,
        message: "Entry retrieved successfully",
        data: {
          entry,
        },
      });
    } catch (error: any) {
      console.error("Get entry detail error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };

  // Update entry
  updateEntry = async (req: AuthRequest, res: Response) => {
    try {
      const entryId = Number(req.params.id);

      if (!Number.isInteger(entryId) || entryId <= 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid entry ID",
        });
      }

      // Check whether entry belongs to the logged-in user
      const existingEntry = await db.query.foodEntriesTable.findFirst({
        where: and(
          eq(foodEntriesTable.id, entryId),
          eq(foodEntriesTable.userId, req.user!.id),
        ),
      });

      if (!existingEntry) {
        return res.status(404).json({
          success: false,
          message: "Entry not found",
        });
      }

      // Validate request body
      const validation = updateEntrySchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: validation.error.flatten().fieldErrors,
        });
      }

      const {
        menuName,
        placeName,
        category,
        price,
        dateTried,
        rating,
        notes,
        isPublic,
      } = validation.data;

      if (Object.keys(validation.data).length === 0 && !req.file) {
        return res.status(400).json({
          success: false,
          message: "Provide at least one field or a new photo",
        });
      }

      // Prepare updated data
      const updateData: Partial<typeof foodEntriesTable.$inferInsert> = {};

      if (menuName !== undefined) updateData.menuName = menuName;
      if (placeName !== undefined) updateData.placeName = placeName || null;
      if (category !== undefined) updateData.category = category;
      if (price !== undefined) updateData.price = price.toFixed(2);
      if (dateTried !== undefined) updateData.dateTried = dateTried;
      if (rating !== undefined) updateData.rating = rating;
      if (notes !== undefined) updateData.notes = notes || null;
      if (isPublic !== undefined) updateData.isPublic = isPublic;

      // Upload new photo if provided
      if (req.file) {
        const uploadResult = await uploadToCloudinary(req.file.buffer);
        updateData.photoUrl = uploadResult.secure_url;
      }

      // Update database
      await db
        .update(foodEntriesTable)
        .set(updateData)
        .where(
          and(
            eq(foodEntriesTable.id, entryId),
            eq(foodEntriesTable.userId, req.user!.id),
          ),
        );

      // Get updated entry
      const updatedEntry = await db.query.foodEntriesTable.findFirst({
        where: and(
          eq(foodEntriesTable.id, entryId),
          eq(foodEntriesTable.userId, req.user!.id),
        ),
      });

      return res.status(200).json({
        success: true,
        message: "Entry updated successfully",
        data: {
          entry: updatedEntry,
        },
      });
    } catch (error: any) {
      console.error("Update entry error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };

  // Delete entry
  deleteEntry = async (req: AuthRequest, res: Response) => {
    try {
      const entryId = Number(req.params.id);

      if (!Number.isInteger(entryId) || entryId <= 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid entry ID",
        });
      }

      // Check whether entry belongs to the logged-in user
      const existingEntry = await db.query.foodEntriesTable.findFirst({
        where: and(
          eq(foodEntriesTable.id, entryId),
          eq(foodEntriesTable.userId, req.user!.id),
        ),
      });

      if (!existingEntry) {
        return res.status(404).json({
          success: false,
          message: "Entry not found",
        });
      }

      // Delete entry from database
      await db
        .delete(foodEntriesTable)
        .where(
          and(
            eq(foodEntriesTable.id, entryId),
            eq(foodEntriesTable.userId, req.user!.id),
          ),
        );

      return res.status(200).json({
        success: true,
        message: "Entry deleted successfully",
      });
    } catch (error: any) {
      console.error("Delete entry error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };
}

export default new EntriesController();
