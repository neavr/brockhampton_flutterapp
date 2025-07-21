<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
        'name',
        'category',
        'brand',
        'description',
        'price',
        'stock',
        'image_url',
    ];

    public function getImageUrlAttribute($value)
    {
        return asset('storage/' . $value); // will return full URL like http://127.0.0.1:8000/storage/products/fate.jpg
    }

}
