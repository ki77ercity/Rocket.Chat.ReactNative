import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { FlatListProps, StyleSheet } from 'react-native';
import { FlatList } from 'react-native-gesture-handler';
import Animated, { runOnJS, useAnimatedScrollHandler } from 'react-native-reanimated';

import { isIOS } from '../../../lib/methods/helpers';
import scrollPersistTaps from '../../../lib/methods/helpers/scrollPersistTaps';
import NavBottomFAB, { SCROLL_LIMIT } from './NavBottomFAB';

const styles = StyleSheet.create({
	list: {
		flex: 1
	},
	contentContainer: {
		paddingTop: 10
	}
});

export type TListRef = React.RefObject<FlatList & { getNode: () => FlatList }>;

export interface IListProps extends FlatListProps<any> {
	listRef: TListRef;
	jumpToBottom: () => void;
	isThread: boolean;
}

const List = ({ listRef, jumpToBottom, isThread, ...props }: IListProps) => {
	const [visible, setVisible] = useState(false);

	const scrollHandler = useAnimatedScrollHandler({
		onScroll: event => {
			if (event.contentOffset.y > SCROLL_LIMIT) {
				runOnJS(setVisible)(true);
			} else {
				runOnJS(setVisible)(false);
			}
		}
	});

	return (
		<>
			<Animated.FlatList
				testID='room-view-messages'
				ref={listRef}
				keyExtractor={(item: any) => item.id}
				contentContainerStyle={styles.contentContainer}
				style={styles.list}
				removeClippedSubviews={isIOS}
				initialNumToRender={7}
				onEndReachedThreshold={0.5}
				maxToRenderPerBatch={5}
				windowSize={10}
				scrollEventThrottle={16}
				onScroll={scrollHandler}
				{...props}
				{...scrollPersistTaps}
			/>
			<NavBottomFAB visible={visible} onPress={jumpToBottom} isThread={isThread} />
		</>
	);
};

List.propTypes = {
	listRef: PropTypes.object
};

export default List;
