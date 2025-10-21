<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TaskType extends Model
{
    protected $fillable = [
        'category_id',
        'name',
        'name_en',
        'description',
        'icon',
        'color',
        'price_range',
        'duration',
        'difficulty',
        'status',
    ];

    // Relationships
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}
