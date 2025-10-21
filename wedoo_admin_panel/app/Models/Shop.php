<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Shop extends Model
{
    protected $fillable = [
        'name',
        'name_en',
        'description',
        'owner_name',
        'phone',
        'email',
        'address',
        'governorate',
        'city',
        'district',
        'latitude',
        'longitude',
        'image',
        'gallery',
        'website',
        'facebook',
        'instagram',
        'whatsapp',
        'rating',
        'rating_count',
        'status',
    ];

    protected $casts = [
        'gallery' => 'array',
    ];

    // Relationships
    public function ratings()
    {
        return $this->hasMany(Rating::class);
    }
}
