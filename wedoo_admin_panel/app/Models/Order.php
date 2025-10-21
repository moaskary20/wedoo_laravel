<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'customer_id',
        'craftsman_id',
        'task_type_id',
        'title',
        'description',
        'location',
        'governorate',
        'city',
        'district',
        'budget',
        'preferred_date',
        'status',
        'notes',
    ];

    protected $casts = [
        'preferred_date' => 'datetime',
    ];

    // Relationships
    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function craftsman()
    {
        return $this->belongsTo(User::class, 'craftsman_id');
    }

    public function taskType()
    {
        return $this->belongsTo(TaskType::class);
    }
}
