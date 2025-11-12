<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TaskType extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'name',
        'name_ar',
        'name_fr',
        'description',
        'icon',
        'color',
        'price_range',
        'duration',
        'difficulty',
        'status',
    ];

    protected $casts = [
        'status' => 'string',
        'difficulty' => 'string',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}