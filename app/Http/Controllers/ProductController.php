<?php
namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::query();

        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        return $query->orderBy('created_at', 'desc')->get();
    }

    public function store(Request $request)
    {
        $request->validate([
            'name'        => 'required|string',
            'category'    => 'required|string',
            'brand'       => 'required|string',
            'description' => 'nullable|string',
            'price'       => 'required|numeric',
            'stock'       => 'required|integer',
            'image'       => 'nullable|image|max:2048',
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('products', 'public');
        }

        $product = Product::create([
            'name'        => $request->name,
            'category'    => $request->category,
            'brand'       => $request->brand,
            'description' => $request->description,
            'price'       => $request->price,
            'stock'       => $request->stock,
            'image_url'   => $imagePath,
        ]);

        return response()->json($product, 201);
    }

    public function show(Product $product)
    {
        return $product;
    }

    public function update(Request $request, Product $product)
    {
        $validated = $request->validate([
            'name'        => 'required|string',
            'category'    => 'required|string',
            'brand'       => 'required|string',
            'price'       => 'required|numeric|min:0',
            'stock'       => 'required|integer|min:0',
            'description' => 'nullable|string',
            'image'       => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($request->hasFile('image')) {
            // delete old image if needed
            if ($product->image_url) {
                Storage::disk('public')->delete($product->image_url);
            }
            $validated['image_url'] = $request->file('image')->store('products', 'public');
        }

        $product->update($validated);

        return $product;
    }

    public function updateWithImage(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $product->name        = $request->name;
        $product->category    = $request->category;
        $product->brand       = $request->brand;
        $product->price       = $request->price;
        $product->stock       = $request->stock;
        $product->description = $request->description;

        if ($request->hasFile('image')) {
            $image              = $request->file('image');
            $path               = $image->store('images', 'public');
            $product->image_url = $path;
        }

        $product->save();

        return response()->json(['success' => true, 'product' => $product]);
    }

    public function destroy(Product $product)
    {
        $product->delete();
        return response()->noContent();
    }

    public function decreaseStock(Request $request, $id)
    {
        $product = Product::find($id);

        if (! $product) {
            return response()->json(['message' => 'Product not found'], 404);
        }

        $quantity = $request->input('quantity', 1);

        if ($product->stock < $quantity) {
            return response()->json(['message' => 'Not enough stock'], 400);
        }

        $product->stock -= $quantity;
        $product->save();

        return response()->json(['message' => 'Stock updated successfully'], 200);
    }

}
