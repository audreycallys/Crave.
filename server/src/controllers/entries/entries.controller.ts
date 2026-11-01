import { Request, Response } from "express";
import { db } from "../../config/db";
import { foodEntriesTable } from "../../config/schema";
import { eq, desc } from "drizzle-orm";
import {
  createEntrySchema,
  updateEntrySchema,
} from "../../validations/entries/entries.validation";
import { uploadToCloudinary } from "../../services/cloudinary.service";

export class EntriesController {
  createEntry = async (req: Request, res: Response) => {
    try {
      // Validation
      const validation = createEntrySchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: validation.error.flatten().fieldErrors,
        });
      }

      const {
        userId,
        menuName,
        placeName,
        category,
        price,
        dateTried,
        rating,
        notes,
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
          userId,
          menuName,
          placeName: placeName || null,
          category,
          price: price.toFixed(2),
          dateTried,
          rating,
          photoUrl,
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

  // Get all entries
  getAllEntries = async (req: Request, res: Response) => {
    try {
      const entries = await db
        .select()
        .from(foodEntriesTable)
        .orderBy(desc(foodEntriesTable.createdAt));

      return res.status(200).json({
        success: true,
        message: "Entries retrieved successfully",
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

  // Get entry by ID
  getEntryById = async (req: Request, res: Response) => {
    try {
      const entryId = Number(req.params.id);

      if (!Number.isInteger(entryId) || entryId <= 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid entry ID",
        });
      }

      const entry = await db.query.foodEntriesTable.findFirst({
        where: eq(foodEntriesTable.id, entryId),
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
  updateEntry = async (req: Request, res: Response) => {
    try {
      const entryId = Number(req.params.id);

      if (!Number.isInteger(entryId) || entryId <= 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid entry ID",
        });
      }

      // Check whether entry exists
      const existingEntry = await db.query.foodEntriesTable.findFirst({
        where: eq(foodEntriesTable.id, entryId),
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

      const { menuName, placeName, category, price, dateTried, rating, notes } =
        validation.data;

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

      // Upload new photo if provided
      if (req.file) {
        const uploadResult = await uploadToCloudinary(req.file.buffer);
        updateData.photoUrl = uploadResult.secure_url;
      }

      // Update database
      await db
        .update(foodEntriesTable)
        .set(updateData)
        .where(eq(foodEntriesTable.id, entryId));

      // Get updated entry
      const updatedEntry = await db.query.foodEntriesTable.findFirst({
        where: eq(foodEntriesTable.id, entryId),
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
}

export default new EntriesController();
