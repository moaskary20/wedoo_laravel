<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Shop;

class ShopController extends Controller
{
    public function list()
    {
        $shops = Shop::where('status', 'active')
            ->get()
            ->map(function ($shop) {
                return [
                    'id' => $shop->id,
                    'name' => $shop->name,
                    'name_en' => $shop->name_en,
                    'description' => $shop->description,
                    'owner_name' => $shop->owner_name,
                    'phone' => $shop->phone,
                    'email' => $shop->email,
                    'address' => $shop->address,
                    'governorate' => $shop->governorate,
                    'city' => $shop->city,
                    'district' => $shop->district,
                    'latitude' => $shop->latitude,
                    'longitude' => $shop->longitude,
                    'image' => $shop->image,
                    'gallery' => $shop->gallery,
                    'website' => $shop->website,
                    'facebook' => $shop->facebook,
                    'instagram' => $shop->instagram,
                    'whatsapp' => $shop->whatsapp,
                    'rating' => $shop->rating,
                    'rating_count' => $shop->rating_count,
                    'status' => $shop->status,
                    'created_at' => $shop->created_at->format('Y-m-d')
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $shops,
            'message' => 'Shops retrieved successfully'
        ]);
    }

    public function show(Request $request)
    {
        $shopId = $request->get('id');
        $shop = Shop::find($shopId);

        if (!$shop) {
            return response()->json([
                'success' => false,
                'message' => 'Shop not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $shop->id,
                'name' => $shop->name,
                'name_en' => $shop->name_en,
                'description' => $shop->description,
                'owner_name' => $shop->owner_name,
                'phone' => $shop->phone,
                'email' => $shop->email,
                'address' => $shop->address,
                'governorate' => $shop->governorate,
                'city' => $shop->city,
                'district' => $shop->district,
                'latitude' => $shop->latitude,
                'longitude' => $shop->longitude,
                'image' => $shop->image,
                'gallery' => $shop->gallery,
                'website' => $shop->website,
                'facebook' => $shop->facebook,
                'instagram' => $shop->instagram,
                'whatsapp' => $shop->whatsapp,
                'rating' => $shop->rating,
                'rating_count' => $shop->rating_count,
                'status' => $shop->status,
                'created_at' => $shop->created_at->format('Y-m-d')
            ],
            'message' => 'Shop retrieved successfully'
        ]);
    }
}
