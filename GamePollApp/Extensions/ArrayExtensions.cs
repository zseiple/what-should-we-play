using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GamePollApp.Extensions.Array
{
    public static class ArrayExtensions
    {
        /// <summary>
        /// Given an source array, returns a new array only including (length) elements from the source array starting from (startIndex)
        /// </summary>
        /// <typeparam name="T">Type of Array</typeparam>
        /// <param name="source"></param>
        /// <param name="startIndex">The index in the source array to start the splice on</param>
        /// <param name="length">the number of elements from startIndex in the source array to include in result array</param>
        /// <returns></returns>
        public static T[] Splice<T>(this T[] source, int startIndex, int length)
        {
            T[] buffer = new T[length];
            System.Array.Copy(source, startIndex, buffer, 0, length);
            return buffer;
        }

    }
}
