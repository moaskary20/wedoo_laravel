<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    protected $fillable = [
        'name',
        'name_en',
        'description',
        'icon',
        'image',
        'status',
    ];

    // Relationships
    public function taskTypes()
    {
        return $this->hasMany(TaskType::class);
    }

    public function craftsmen()
    {
        return $this->hasMany(User::class, 'category_id')->where('user_type', 'craftsman');
    }
}
