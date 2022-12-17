/*

General Templatized C++ List Class
Holds references to objects

*/

#include "sp_stand.cpp"
#include <stdio.h>

template <class T> class listItem : Object
{

private:
	T listItemData;
	listItem* next;
public:
	listItem(void) { next = NULL; }
	listItem(T itemData) { listItemData = itemData; }
	listItem(T itemData, listItem* nextItem) { listItemData = itemData;
						   next = nextItem; }
	listItem* getNext(void) { return next; }
//	Boolean   setNext(listItem sn) { next = sn; return OK; }
}

template <class A> class list : Object
{

private:
	Boolean blankList;
	listItem<A> firstItem;
	listItem<A> newItem;

public:
	list(void) { blankList = TRUE; }
	Boolean addItem(A item)
	{
		if (blankList == FALSE)
		{
			newItem = firstItem;
			firstItem = new listItem<A> (item, &newItem);
		}
		else
		{
			firstItem = new listItem<A> (item);
			blankList = FALSE;
		}
	}
	listItem<A>* getFirstItem(void) { return firstItem; }
}