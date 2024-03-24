import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import { me } from 'mastodon/initial_state';
import { HASHTAG_PATTERN_REGEX } from 'mastodon/utils/hashtags';

import Warning from '../components/warning';

const mapStateToProps = state => ({
  needsLockWarning: state.getIn(['compose', 'privacy']) === 'private' && !state.getIn(['accounts', me, 'locked']),
  hashtagWarning: state.getIn(['compose', 'privacy']) !== 'public' && HASHTAG_PATTERN_REGEX.test(state.getIn(['compose', 'text'])),
  directMessageWarning: state.getIn(['compose', 'privacy']) === 'direct',
});

const WarningWrapper = ({ needsLockWarning, hashtagWarning }) => {
  if (needsLockWarning) {
    return <Warning message={<FormattedMessage id='compose_form.lock_disclaimer' defaultMessage='Your account is not {locked}. Anyone can follow you to view your follower-only posts.' values={{ locked: <a href='/settings/profile'><FormattedMessage id='compose_form.lock_disclaimer.lock' defaultMessage='locked' /></a> }} />} />;
  }

  if (hashtagWarning) {
    return <Warning message={<FormattedMessage id='compose_form.hashtag_warning' defaultMessage="This post won't be listed under any hashtag as it is unlisted. Only public posts can be searched by hashtag." />} />;
  }

  return null;
};

WarningWrapper.propTypes = {
  needsLockWarning: PropTypes.bool,
  hashtagWarning: PropTypes.bool,
  directMessageWarning: PropTypes.bool,
};

export default connect(mapStateToProps)(WarningWrapper);
