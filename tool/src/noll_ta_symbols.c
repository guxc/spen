/**************************************************************************/
/*                                                                        */
/*  NOLL decision procedure                                               */
/*                                                                        */
/*  Copyright (C) 2013                                                    */
/*    LIAFA (University of Paris Diderot and CNRS)                        */
/*    VeriFIT (Brno University of Technology)                             */
/*                                                                        */
/*                                                                        */
/*  you can redistribute it and/or modify it under the terms of the GNU   */
/*  Lesser General Public License as published by the Free Software       */
/*  Foundation, version 3.                                                */
/*                                                                        */
/*  It is distributed in the hope that it will be useful,                 */
/*  but WITHOUT ANY WARRANTY; without even the implied warranty of        */
/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         */
/*  GNU Lesser General Public License for more details.                   */
/*                                                                        */
/*  See the GNU Lesser General Public License version 3.                  */
/*  for more details (enclosed in the file LICENSE).                      */
/*                                                                        */
/**************************************************************************/

#include "noll.h"
#include "noll_ta_symbols.h"

/* ====================================================================== */
/* Data typez */
/* ====================================================================== */

typedef struct noll_ta_symbol_t
{
	/// The selectors
	const noll_uid_array* sels;
	/// The string representation (for humans)
	const char* str;
} noll_ta_symbol_t;

// a database of symbols
NOLL_VECTOR_DECLARE( noll_ta_symbol_array , noll_ta_symbol_t* )
NOLL_VECTOR_DEFINE( noll_ta_symbol_array , noll_ta_symbol_t* )

/* ====================================================================== */
/* Globalz */
/* ====================================================================== */

static noll_ta_symbol_array* g_ta_symbols;

/* ====================================================================== */
/* Functionz */
/* ====================================================================== */


/**
 * @brief  Checks whether two symbols match
 *
 * @param[in]  lhs  The left-hand side
 * @param[in]  rhs  The right-hand side
 *
 * @returns  @p true if @p lhs and @p rhs match, @p false otherwise
 */
bool noll_ta_symbol_match(
	const noll_ta_symbol_t*       lhs,
	const noll_ta_symbol_t*       rhs)
{
	// check that the parameters are sane
	assert(NULL != lhs);
	assert(NULL != rhs);
	assert(NULL != lhs->sels);
	assert(NULL != rhs->sels);

	if (noll_vector_size(lhs->sels) != noll_vector_size(rhs->sels))
	{
		return false;
	}

	// the order of the selectors needs to match
	for (size_t i = 0; i < noll_vector_size(lhs->sels); ++i)
	{
		if (noll_vector_at(lhs->sels, i) != noll_vector_at(rhs->sels, i))
		{
			return false;
		}
	}

	return true;
}


const char* noll_ta_symbol_get_str(
	const noll_ta_symbol_t*       symb)
{
	// check inputs
	assert(NULL != symb);
	assert(NULL != symb->str);

	return symb->str;
}


/**
 * @brief  Generates a string for a TA symbol from selectors
 *
 * This function generates a human-readable string for a textual representation
 * of a TA symbol composed from a vector of selectors. The function returns a
 * non-shared dynamically allocated memory block---it is the responsibility of
 * the caller to dispose of it.
 *
 * @param[in]  sels  The selectors from which the symbol is to be composed
 *
 * @returns  Pointer to a dynamically allocated memory block with the
 *           human-readable representation of the symbol. After the return, the
 *           caller is responsible for deallocating this block.
 */
const char* noll_sels_to_string_symbol(
	const noll_uid_array*           sels)
{
	// check that the caller is not mischievous
	assert(NULL != sels);

	// compute the necessary memory for the string
	size_t str_len = 3;                          // for '<', '>', and '\0'
	str_len += (noll_vector_size(sels)-1) * 2;   // for (n-1) * ", "
	for (size_t i = 0; i < noll_vector_size(sels); ++i)
	{
		const char* field_name = noll_field_name(noll_vector_at(sels, i));
		assert(NULL != field_name);
		NOLL_DEBUG("Processing field %u with the name %s\n", noll_vector_at(sels, i), field_name);

		str_len += strlen(field_name);
	}

	char* str_symbol = malloc(str_len);
	assert(NULL != str_symbol);


	str_symbol[0] = '<';
	size_t cnt = 1;      // where to start copying
	for (size_t i = 0; i < noll_vector_size(sels); ++i)
	{
		if (1 != cnt)
		{	// if we are not at the beginning
			str_symbol[cnt++] = ',';
			str_symbol[cnt++] = ' ';
		}

		const char* field_name = noll_field_name(noll_vector_at(sels, i));
		strcpy(&str_symbol[cnt], field_name);
		cnt += strlen(field_name);
	}

	// check that everything is correct
	assert(cnt == str_len - 2);

	str_symbol[str_len-2] = '>';
	str_symbol[str_len-1] = '\0';

	return str_symbol;
}


void noll_ta_symbol_init()
{
	g_ta_symbols = noll_ta_symbol_array_new();
	noll_ta_symbol_array_reserve(g_ta_symbols, 10);
}


void noll_ta_symbol_destroy()
{
	assert(false);
	// NOT IMPLEMENTED!!!!
}


/**
 * @brief  Attempts to find a given in the global database
 *
 * @param[in]  symb  The symbol to be sought
 *
 * @returns  Either a pointer to the unique representation of the symbol @p
 *           symb if it exists, or @p NULL if it does not exist
 */
const noll_ta_symbol_t* noll_ta_symbol_find(
	const noll_ta_symbol_t*           symb)
{
	assert(NULL != symb);
	assert(NULL != g_ta_symbols);

	for (size_t i = 0; i < noll_vector_size(g_ta_symbols); ++i)
	{
		const noll_ta_symbol_t* iter = noll_vector_at(g_ta_symbols, i);
		if (noll_ta_symbol_match(symb, iter))
		{
			return iter;
		}
	}

	return NULL;
}

const noll_ta_symbol_t* noll_ta_symbol_create(
	const noll_uid_array*            sels)
{
	// check for the input parameters
	assert(NULL != sels);
	assert(NULL != g_ta_symbols);

	noll_ta_symbol_t symb;
	symb.sels = sels;

	const noll_ta_symbol_t* ret_symb;
	if ((ret_symb = noll_ta_symbol_find(&symb)) != NULL)
	{
		return ret_symb;
	}

	noll_ta_symbol_t* alloc_symb = malloc(sizeof(*alloc_symb));
	assert(NULL != alloc_symb);
	noll_uid_array* alloc_sels = noll_uid_array_new();
	assert(NULL != alloc_sels);
	noll_uid_array_copy(alloc_sels, sels);
	alloc_symb->sels = alloc_sels;

	alloc_symb->str = noll_sels_to_string_symbol(sels);
	assert(NULL != alloc_symb->str);

	NOLL_DEBUG("Inserting new symbol: %s\n", alloc_symb->str);

	noll_ta_symbol_array_push(g_ta_symbols, alloc_symb);

	return alloc_symb;
}