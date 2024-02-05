﻿using Microsoft.Xna.Framework;
using Monofoxe.Engine.Collisions.Algorithms;
using System;
using System.Collections.Generic;

namespace Monofoxe.Engine.Collisions
{
	public static class ColliderFactory
	{

		public static Collider CreateCircle(float r)
		{
			var collider = ColliderPool.GetCollider();

			var circle = ShapePool.GetCircle();
			circle.Radius = r;
			collider.AddShape(circle);

			return collider;
		}


		public static Collider CreateRectangle(Vector2 size)
		{
			var collider = ColliderPool.GetCollider();
			var poly = ShapePool.GetPolygon();

			var halfSize = size / 2;

			// 0---1
			// | \ |
			// 3---2
			poly.Add(new Vector2(-halfSize.X, -halfSize.Y));
			poly.Add(new Vector2( halfSize.X, -halfSize.Y));
			poly.Add(new Vector2( halfSize.X,  halfSize.Y));
			poly.Add(new Vector2(-halfSize.X,  halfSize.Y));

			collider.AddShape(poly);

			return collider;
		}


		public static Collider CreateLine(float length)
		{
			var collider = ColliderPool.GetCollider();
			var poly = ShapePool.GetPolygon();

			poly.Add(new Vector2(0, 0));
			poly.Add(new Vector2(length, 0));

			collider.AddShape(poly);

			return collider;
		}


		public static Collider CreateRing(float arc, float r, float thickness)
		{
			throw new NotImplementedException();
		}


		public static Collider CreateSector(float arc, float r)
		{
			throw new NotImplementedException();
		}


		public static Collider CreatePolygon(List<Vector2> vertices)
		{
			var collider = ColliderPool.GetCollider();

			var polys = BayazitDecomposer.ConvexPartition(vertices);

			for (var i = 0; i < polys.Count; i += 1)
			{
				var poly = ShapePool.GetPolygon();

				for (var k = 0; k < polys[i].Count; k += 1)
				{
					poly.Add(polys[i][k]);
				}

				collider.AddShape(poly);
			}

			return collider;
		}
	}
}
